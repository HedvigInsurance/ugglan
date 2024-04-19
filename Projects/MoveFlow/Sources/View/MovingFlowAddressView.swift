import Flow
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct MovingFlowAddressView: View {
    @StateObject var vm: AddressInputModel
    @EnvironmentObject var router: Router

    var body: some View {
        switch vm.store.state.selectedHousingType {
        case .apartment, .rental:
            form.retryView(MoveFlowStore.self, forAction: .requestMoveIntent, binding: $vm.error)
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
                    if vm.isStudentEnabled {
                        hSection {
                            isStudentField()
                        }
                        .sectionContainerStyle(.opaque)
                    }
                }
                .disableOn(MoveFlowStore.self, [.requestMoveIntent])
                hSection {
                    InfoCard(text: L10n.changeAddressCoverageInfoText, type: .info)
                }
                hSection {
                    hButton.LargeButton(type: .primary) {
                        continuePressed()
                    } content: {
                        hText(vm.continueButtonTitle, style: .body)
                    }
                    .trackLoading(MoveFlowStore.self, action: .requestMoveIntent)
                }

            }
            .padding(.bottom, 8)
            .padding(.top, 16)

        }
        .hFormTitle(title: .init(.standard, .title1, L10n.changeAddressEnterNewAddressTitle))
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
            error: $vm.squareAreaError
        )
    }
    func numberOfCoinsuredField() -> some View {
        hCounterField(
            value: $vm.nbOfCoInsured,
            placeholder: L10n.changeAddressCoInsuredLabel,
            minValue: 0,
            maxValue: (vm.store.state.movingFlowModel?.maxNumberOfCoinsuredFor(vm.store.state.selectedHousingType) ?? 5)
                + 1
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
        let minStartDate = vm.store.state.movingFlowModel?.minMovingDate.localDateToDate
        let maxStartDate = vm.store.state.movingFlowModel?.maxMovingDate.localDateToDate

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
        Toggle(isOn: $vm.isStudent.animation(.default)) {
            VStack(alignment: .leading, spacing: 0) {
                hText(L10n.changeAddressStudentLabel, style: .standardLarge)
            }
        }
        .toggleStyle(ChecboxToggleStyle(.center, spacing: 0))
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                vm.isStudent.toggle()
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
    }

    func continuePressed() {
        if vm.isInputValid() {
            switch vm.store.state.selectedHousingType {
            case .apartment, .rental:
                vm.store.send(.requestMoveIntent)
            case .house:
                router.push(MovingFlowRouterActions.houseFill)
                break
            }
        }
    }
}

struct SelectAddress_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        return VStack { MovingFlowAddressView(vm: AddressInputModel()) }
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

public class AddressInputModel: ObservableObject {
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

    @PresentableStore var store: MoveFlowStore

    @Published var error: String?
    var disposeBag = DisposeBag()
    init() {}

    func isInputValid() -> Bool {
        func validate() -> Bool {
            withAnimation {
                addressError = !address.isEmpty ? nil : L10n.changeAddressStreetError
                postalCodeError = !postalCode.isEmpty ? nil : L10n.changeAddressPostalCodeError
                validateSquareArea()
                accessDateError = accessDate?.localDateString != nil ? nil : L10n.changeAddressMovingDateError
                return addressError == nil && postalCodeError == nil && squareAreaError == nil && accessDateError == nil
            }
        }
        return validate()
    }

    private func validateSquareArea() {
        squareAreaError = !squareArea.isEmpty ? nil : L10n.changeAddressLivingSpaceError
        if let size = Int(squareArea) {
            let sizeToCompare: Int? = {
                switch store.state.selectedHousingType {
                case .apartment, .rental:
                    return store.state.movingFlowModel?.maxApartmentSquareMeters
                case .house:
                    return store.state.movingFlowModel?.maxHouseSquareMeters
                }
            }()
            if let sizeToCompare {
                squareAreaError = size < sizeToCompare ? nil : L10n.changeAddressLivingSpaceOverLimitError
            }
        }
    }

    func clearErrors() {
        error = nil
        addressError = nil
        postalCodeError = nil
        squareAreaError = nil
        accessDateError = nil
    }

    var isStudentEnabled: Bool {
        switch store.state.selectedHousingType {
        case .apartment, .rental:
            return store.state.movingFlowModel?.isApartmentAvailableforStudent ?? false
        case .house:
            return false
        }
    }

    var continueButtonTitle: String {
        switch store.state.selectedHousingType {
        case .apartment, .rental:
            return L10n.saveAndContinueButtonLabel
        case .house:
            return L10n.saveAndContinueButtonLabel
        }
    }
}
