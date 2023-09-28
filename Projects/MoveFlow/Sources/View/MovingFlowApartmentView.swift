import Flow
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct MovingFlowNewAddressView: View {
    @StateObject var vm = MovingFlowNewAddressViewModel()

    var body: some View {
        hForm {
            VStack(spacing: 16) {
                VStack(spacing: 4) {
                    hSection {
                        addressField().disableOn(MoveFlowStore.self, [.requestMoveIntent])
                    }
                    hSection {
                        postalAndSquareField().disableOn(MoveFlowStore.self, [.requestMoveIntent])
                    }
                    hSection {
                        numberOfCoinsuredField().disableOn(MoveFlowStore.self, [.requestMoveIntent])
                    }
                    hSection {
                        accessDateField().disableOn(MoveFlowStore.self, [.requestMoveIntent])
                    }
                    if vm.store.state.selectedHousingType.isStudentEnabled {
                        hSection {
                            isStudentField().disableOn(MoveFlowStore.self, [.requestMoveIntent])
                        }
                        .sectionContainerStyle(.opaque)
                    }
                }
                hSection {
                    InfoCard(text: L10n.changeAddressCoverageInfoText, type: .info)
                }
                hSection {
                    hButton.LargeButton(type: .primary) {
                        vm.continuePressed()
                    } content: {
                        hText(L10n.General.submit, style: .body)
                    }
                    .trackLoading(MoveFlowStore.self, action: .requestMoveIntent)
                }
            }
            .padding(.bottom, 8)
            .padding(.top, 16)

        }
        .hFormTitle(.standard, .title1, L10n.changeAddressEnterNewAddressTitle)
        .sectionContainerStyle(.transparent)
        .hFormContentPosition(.bottom)
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

    func postalAndSquareField() -> some View {
        HStack(alignment: .top, spacing: 4) {
            hFloatingTextField(
                masking: Masking(type: .postalCode),
                value: $vm.postalCode,
                equals: $vm.type,
                focusValue: .postalCode,
                placeholder: L10n.changeAddressNewPostalCodeLabel,
                error: $vm.postalCodeError
            )

            hFloatingTextField(
                masking: Masking(type: .digits),
                value: $vm.squareArea,
                equals: $vm.type,
                focusValue: .squareArea,
                placeholder: L10n.changeAddressNewLivingSpaceLabel,
                suffix: L10n.changeAddressSizeSuffix,
                error: $vm.squareAreaError
            )
        }
    }

    func numberOfCoinsuredField() -> some View {
        hFloatingTextField(
            masking: Masking(type: .digits),
            value: $vm.nbOfCoInsured,
            equals: $vm.type,
            focusValue: .nbOfCoInsured,
            placeholder: L10n.changeAddressCoInsuredLabel,
            error: $vm.nbOfCoInsuredError
        )
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
                vm.type = .accessDate
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
}

struct SelectAddress_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .sv_SE
        return MovingFlowNewAddressView()
    }
}

enum MovingFlowNewAddressViewFieldType: hTextFieldFocusStateCompliant {
    static var last: MovingFlowNewAddressViewFieldType {
        return MovingFlowNewAddressViewFieldType.accessDate
    }

    var next: MovingFlowNewAddressViewFieldType? {
        switch self {
        case .address:
            return .postalCode
        case .postalCode:
            return .squareArea
        case .squareArea:
            return .nbOfCoInsured
        case .nbOfCoInsured:
            return .accessDate
        case .accessDate:
            return nil
        }
    }

    case address
    case postalCode
    case squareArea
    case nbOfCoInsured
    case accessDate

}

class MovingFlowNewAddressViewModel: ObservableObject {
    @Published var type: MovingFlowNewAddressViewFieldType?
    @Published var address: String = ""
    @Published var postalCode: String = ""
    @Published var squareArea: String = ""
    @Published var nbOfCoInsured: String = ""
    @Published var accessDate: Date?
    @Published var isStudent = false

    @Published var addressError: String?
    @Published var postalCodeError: String?
    @Published var squareAreaError: String?
    @Published var nbOfCoInsuredError: String?
    @Published var accessDateError: String?

    @PresentableStore var store: MoveFlowStore

    init() {
        let store: MoveFlowStore = globalPresentableStoreContainer.get()
        self.nbOfCoInsured = String(store.state.movingFlowModel?.numberCoInsured ?? 0)
    }

    var disposeBag = DisposeBag()
    func continuePressed() {
        if isInputValid() {
            store.send(.setNewAddress(with: self.toNewAddressModel()))
            switch store.state.selectedHousingType {
            case .apartmant, .rental:
                store.send(.requestMoveIntent)
            case .house:
                store.send(.navigation(action: .openHouseFillScreen))
            }
        }
    }

    private func isInputValid() -> Bool {
        func validate() -> Bool {
            withAnimation {
                addressError = !address.isEmpty ? nil : L10n.changeAddressStreetError
                postalCodeError = !postalCode.isEmpty ? nil : L10n.changeAddressPostalCodeError
                squareAreaError = !squareArea.isEmpty ? nil : L10n.changeAddressLivingSpaceError
                nbOfCoInsuredError = !nbOfCoInsured.isEmpty ? nil : L10n.changeAddressCoInsuredError
                accessDateError = accessDate?.localDateString != nil ? nil : L10n.changeAddressMovingDateError
                return addressError == nil && postalCodeError == nil && squareAreaError == nil
                    && nbOfCoInsuredError == nil && accessDateError == nil
            }
        }
        return validate()
    }
}

extension MovingFlowNewAddressViewModel {
    func toNewAddressModel() -> NewAddressModel {
        NewAddressModel(
            address: self.address,
            postalCode: self.postalCode,
            movingDate: accessDate?.localDateString ?? "",
            numberOfCoinsured: Int(nbOfCoInsured) ?? 0,
            squareMeters: Int(squareArea) ?? 0,
            isStudent: isStudent
        )
    }
}
