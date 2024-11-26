import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct MovingFlowAddressScreen: View {
    @ObservedObject var vm: AddressInputModel
    @EnvironmentObject var router: Router
    @EnvironmentObject var movingFlowNavigationVm: MovingFlowNavigationViewModel

    public init(
        vm: AddressInputModel
    ) {
        self.vm = vm
    }

    var body: some View {
        switch vm.selectedHousingType {
        case .apartment, .rental:
            form.loadingButtonWithErrorHandling($vm.viewState)
                .hErrorViewButtonConfig(
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
                .disabled(vm.viewState == .loading)
                hSection {
                    InfoCard(text: L10n.changeAddressCoverageInfoText, type: .info)
                }
                hSection {
                    hButton.LargeButton(type: .primary) {
                        continuePressed()
                    } content: {
                        hText(vm.continueButtonTitle, style: .body1)
                    }
                }

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
        .presentableStoreLensAnimation(.default)
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
            maxValue: movingFlowNavigationVm.movingFlowVm?.maxNumberOfCoinsuredFor(vm.selectedHousingType)
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
        let minStartDate = movingFlowNavigationVm.movingFlowVm?.minMovingDate.localDateToDate
        let maxStartDate = movingFlowNavigationVm.movingFlowVm?.maxMovingDate.localDateToDate

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
    func isStudentField() -> some View {
        CheckboxToggleView(
            title: L10n.changeAddressStudentLabel,
            isOn: $vm.isStudent.animation(.default)
        )
        .hFieldSize(.large)
        .onTapGesture {
            withAnimation {
                vm.isStudent.toggle()
            }
        }
    }

    func continuePressed() {
        if isInputValid() {
            switch vm.selectedHousingType {
            case .apartment, .rental:
                Task { @MainActor in
                    if let movingFlowData = await vm.requestMoveIntent(
                        intentId: movingFlowNavigationVm.movingFlowVm?.id ?? ""
                    ) {
                        movingFlowNavigationVm.movingFlowVm = movingFlowData

                        if let changeTierModel = movingFlowData.changeTier {
                            router.push(MovingFlowRouterActions.selectTier(changeTierModel: changeTierModel))
                        } else {
                            router.push(MovingFlowRouterActions.confirm)
                        }
                    }
                }
            case .house:
                router.push(MovingFlowRouterActions.houseFill)
                break
            }
        }
    }

    private func validateSquareArea() {
        vm.squareAreaError = !vm.squareArea.isEmpty ? nil : L10n.changeAddressLivingSpaceError
        if let size = Int(vm.squareArea) {
            let sizeToCompare: Int? = {
                switch vm.selectedHousingType {
                case .apartment, .rental:
                    return movingFlowNavigationVm.movingFlowVm?.maxApartmentSquareMeters
                case .house:
                    return movingFlowNavigationVm.movingFlowVm?.maxHouseSquareMeters
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
            return movingFlowNavigationVm.movingFlowVm?.isApartmentAvailableforStudent ?? false
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

struct SelectAddress_Previews: PreviewProvider {
    static var previews: some View {
        Dependencies.shared.add(module: Module { () -> MoveFlowClient in MoveFlowClientDemo() })
        Localization.Locale.currentLocale.send(.en_SE)
        return VStack { MovingFlowAddressScreen(vm: .init()) }
    }
}

enum MovingFlowNewAddressViewFieldType: hTextFieldFocusStateCompliant, Codable {
    static var last: MovingFlowNewAddressViewFieldType {
        return MovingFlowNewAddressViewFieldType.squareArea
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
public class AddressInputModel: ObservableObject {
    @Inject private var service: MoveFlowClient
    @Published var moveFromAddressId: String?
    @Published var address: String = ""
    @Published var postalCode: String = ""
    @Published var squareArea: String = ""
    @Published var nbOfCoInsured: Int = 0
    @Published var accessDate: Date?
    @Published var isStudent = false
    @Published var addressError: String?
    @Published var postalCodeError: String?
    @Published var squareAreaError: String?
    @Published var accessDateError: String?
    @Published var type: MovingFlowNewAddressViewFieldType?
    @Published var selectedHousingType: HousingType = .apartment
    @Published var viewState: ProcessingState = .success

    @MainActor
    func requestMoveIntent(intentId: String) async -> MovingFlowModel? {
        withAnimation {
            self.viewState = .loading
        }

        do {
            let movingFlowData = try await service.requestMoveIntent(
                intentId: intentId,
                addressInputModel: self,
                houseInformationInputModel: .init()
            )

            withAnimation {
                self.viewState = .success
            }

            return movingFlowData
        } catch {
            self.viewState = .error(errorMessage: error.localizedDescription)
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
