import SwiftUI
import hCore
import hCoreUI

struct MovingFlowAddressScreen: View {
    @Bindable var vm: AddressInputModel
    @Environment(NavigationRouter.self) var router
    @Environment(MovingFlowNavigationViewModel.self) var movingFlowNavigationVm

    init(
        vm: AddressInputModel
    ) {
        self.vm = vm
    }

    var body: some View {
        switch vm.selectedHousingType {
        case .apartment, .rental:
            form.loadingWithButtonLoading($vm.viewState)
                .hStateViewButtonConfig(
                    .init(
                        actionButton: .init(buttonAction: {
                            vm.viewState = .success
                        }),
                        dismissButton: nil
                    )
                )
                .onDisappear {
                    vm.clearErrors()
                }
        case .house:
            form
        }
    }

    var form: some View {
        hForm {
            VStack(spacing: 16) {
                VStack(spacing: 4) {
                    hSection {
                        addressField()
                    }
                    hSection {
                        postalField()
                    }
                    hSection {
                        squareField()
                    }
                    hSection {
                        numberOfCoinsuredField()
                    }
                    hSection {
                        accessDateField()
                    }
                    if isStudentEnabled {
                        isStudentField()
                    }
                }
                .hFieldSize(.medium)
                .disabled(vm.viewState == .loading)
            }
            .padding(.bottom, .padding8)
            .padding(.top, .padding16)
        }
        .hFormTitle(
            title: .init(
                .small,
                .heading2,
                L10n.movingEmbarkTitle,
                alignment: .leading
            ),
            subTitle: .init(
                .standard,
                .heading2,
                L10n.changeAddressEnterNewAddressTitle
            )
        )
        .sectionContainerStyle(.transparent)
        .hFormContentPosition(.bottom)
        .hFormAlwaysAttachToBottom {
            hSection {
                hButton(
                    .large,
                    .primary,
                    content: .init(title: vm.continueButtonTitle)
                ) { continuePressed() }
            }
        }
    }

    func addressField() -> some View {
        hFloatingTextField(
            masking: Masking(type: .address),
            value: $vm.address,
            equals: $vm.type,
            focusValue: .address,
            error: $vm.addressError
        )
    }

    func postalField() -> some View {
        hFloatingTextField(
            masking: Masking(type: .postalCode),
            value: $vm.postalCode,
            equals: $vm.type,
            focusValue: .postalCode,
            placeholder: L10n.changeAddressNewPostalCodeLabel,
            error: $vm.postalCodeError
        )
    }

    func squareField() -> some View {
        hFloatingTextField(
            masking: Masking(type: .digits),
            value: $vm.squareArea,
            equals: $vm.type,
            focusValue: .squareArea,
            placeholder: L10n.changeAddressNewLivingSpaceLabel,
            suffix: "m\u{00B2}",
            error: $vm.squareAreaError
        )
    }

    func numberOfCoinsuredField() -> some View {
        hCounterField(
            value: $vm.nbOfCoInsured,
            placeholder: L10n.changeAddressCoInsuredLabel,
            minValue: 0,
            maxValue: movingFlowNavigationVm.moveConfigurationModel?.maxNumberOfCoinsuredFor(vm.selectedHousingType)
        ) { value in
            vm.type = nil
            if value > 0 {
                return L10n.changeAddressYouPlus(value)
            } else {
                return L10n.changeAddressOnlyYou
            }
        }
    }

    func accessDateField() -> some View {
        let minStartDate = movingFlowNavigationVm.selectedHomeAddress?.minMovingDate.localDateToDate
        let maxStartDate = movingFlowNavigationVm.selectedHomeAddress?.maxMovingDate.localDateToDate

        return hDatePickerField(
            config: .init(
                minDate: minStartDate,
                maxDate: maxStartDate,
                placeholder: L10n.changeAddressMovingDateLabel,
                title: L10n.changeAddressMovingDateLabel
            ),
            selectedDate: vm.accessDate,
            error: $vm.accessDateError,
            onContinue: { date in
                vm.accessDate = date
                vm.type = nil
            },
            onShowDatePicker: {
                vm.type = nil
            }
        )
    }

    @ViewBuilder
    func isStudentField() -> some View {
        CheckboxToggleView(
            title: L10n.changeAddressStudentLabel,
            isOn: $vm.isStudent.animation(.default)
        )
        .onTapGesture {
            withAnimation {
                vm.isStudent.toggle()
            }
        }
        .accessibilityAddTraits(.isButton)
    }

    func continuePressed() {
        if isInputValid() {
            switch vm.selectedHousingType {
            case .apartment, .rental:
                Task { @MainActor in
                    if let requestVm = await vm.requestMoveIntent(
                        intentId: movingFlowNavigationVm.moveConfigurationModel?.id ?? "",
                        selectedAddressId: movingFlowNavigationVm.selectedHomeAddress?.id ?? "",
                        source: movingFlowNavigationVm.source
                    ) {
                        movingFlowNavigationVm.moveQuotesModel = requestVm
                        if let changeTierModel = requestVm.changeTierModel {
                            router.push(MovingFlowRouterActions.selectTier(changeTierModel: changeTierModel))
                        } else {
                            router.push(MovingFlowRouterActions.confirm)
                        }
                    }
                }
            case .house:
                router.push(MovingFlowRouterActions.houseFill)
            }
        }
    }

    private func validateSquareArea() {
        vm.squareAreaError = !vm.squareArea.isEmpty ? nil : L10n.changeAddressLivingSpaceError
        if let size = Int(vm.squareArea) {
            let sizeToCompare: Int? = {
                switch vm.selectedHousingType {
                case .apartment, .rental:
                    return movingFlowNavigationVm.moveConfigurationModel?.maxApartmentSquareMeters
                case .house:
                    return movingFlowNavigationVm.moveConfigurationModel?.maxHouseSquareMeters
                }
            }()
            if let sizeToCompare {
                vm.squareAreaError =
                    size < sizeToCompare
                    ? nil : L10n.changeAddressLivingSpaceOverLimitWithInputError(sizeToCompare, "m\u{00B2}")
            }
        }
    }

    var isStudentEnabled: Bool {
        switch vm.selectedHousingType {
        case .apartment, .rental:
            return movingFlowNavigationVm.moveConfigurationModel?.isApartmentAvailableforStudent ?? false
        case .house:
            return false
        }
    }

    func isInputValid() -> Bool {
        func validate() -> Bool {
            withAnimation {
                vm.addressError = !vm.address.isEmpty ? nil : L10n.changeAddressStreetError
                vm.postalCodeError = !vm.postalCode.isEmpty ? nil : L10n.changeAddressPostalCodeError
                validateSquareArea()
                vm.accessDateError = vm.accessDate?.localDateString != nil ? nil : L10n.changeAddressMovingDateError
                return vm.addressError == nil && vm.postalCodeError == nil && vm.squareAreaError == nil
                    && vm.accessDateError == nil
            }
        }
        return validate()
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> MoveFlowClient in MoveFlowClientDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Localization.Locale.currentLocale.send(.en_SE)
    return VStack { MovingFlowAddressScreen(vm: .init()).environment(MovingFlowNavigationViewModel()) }
}

enum MovingFlowNewAddressViewFieldType: hTextFieldFocusStateCompliant, Codable {
    static var last: MovingFlowNewAddressViewFieldType {
        MovingFlowNewAddressViewFieldType.squareArea
    }

    var next: MovingFlowNewAddressViewFieldType? {
        switch self {
        case .address:
            return .postalCode
        case .postalCode:
            return .squareArea
        case .squareArea:
            return nil
        }
    }

    case address
    case postalCode
    case squareArea
}

@MainActor
@Observable
public class AddressInputModel {
    @ObservationIgnored @Inject private var service: MoveFlowClient
    public var address: String = ""
    public var postalCode: String = ""
    public var squareArea: String = ""
    public var nbOfCoInsured: Int = 0
    public var accessDate: Date?
    public var isStudent = false
    var addressError: String?
    var postalCodeError: String?
    var squareAreaError: String?
    var accessDateError: String?
    var type: MovingFlowNewAddressViewFieldType?
    public var selectedHousingType: HousingType = .apartment
    var viewState: ProcessingState = .success

    @MainActor
    func requestMoveIntent(
        intentId: String,
        selectedAddressId: String,
        source: MovingFlowSource
    ) async -> MoveQuotesModel? {
        withAnimation {
            self.viewState = .loading
        }

        do {
            let input = RequestMoveIntentInput(
                intentId: intentId,
                addressInputModel: self,
                houseInformationInputModel: nil,
                selectedAddressId: selectedAddressId,
                source: source
            )
            let movingFlowData = try await service.requestMoveIntent(
                input: input
            )

            withAnimation {
                self.viewState = .success
            }

            return movingFlowData
        } catch {
            viewState = .error(errorMessage: error.localizedDescription)
        }
        return nil
    }

    func clearErrors() {
        viewState = .success
        addressError = nil
        postalCodeError = nil
        squareAreaError = nil
        accessDateError = nil
    }

    var continueButtonTitle: String {
        switch selectedHousingType {
        case .apartment, .rental:
            return L10n.saveAndContinueButtonLabel
        case .house:
            return L10n.saveAndContinueButtonLabel
        }
    }
}
