import SwiftUI
import hCore
import hCoreUI

struct MovingFlowSelectAddress: View {
    @PresentableStore var store: MoveFlowStore
    @StateObject var vm = MovingFlowViewModel()

    var body: some View {
        //        LoadingViewWithContent(MoveFlowStore.self, [.fetchMoveIntent], [.getMoveIntent]) {
        hForm {
            hSection {
                hRow {
                    addressField()
                }
                hRow {
                    postalAndSquareField()
                }
                hRow {
                    numberOfCoinsuredField()
                }
                hRow {
                    accessDateField()
                }
            }
            .sectionContainerStyle(.transparent)
        }
        //            .hFormTitle(.standard, .title3, L10n.changeAddressEnterNewAddressTitle)
        .hFormAttachToBottom {
            hButton.LargeButtonPrimary {
                store.send(.navigation(action: .openConfirmScreen))
            } content: {
                hText(L10n.generalContinueButton, style: .body)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        //        }
        //        .onChange(of: vm.type) { newValue in
        //            if newValue == nil {
        //                UIApplication.dismissKeyboard()
        //            } else if newValue == .accessDate {
        //                UIApplication.dismissKeyboard()
        //                store.send(.navigation(action: .openDatePickerScreen))
        //            }
        //        }
        //        .dismissKeyboard()
    }

    func addressField() -> some View {
        hFloatingTextField(
            masking: Masking(type: .address),
            value: $vm.address,
            equals: $vm.type,
            focusValue: .address
        )
    }

    func postalAndSquareField() -> some View {
        HStack(spacing: 0) {
            hFloatingTextField(
                masking: Masking(type: .postalCode),
                value: $vm.postalCode,
                equals: $vm.type,
                focusValue: .postalCode,
                placeholder: L10n.changeAddressNewPostalCodeLabel
            )
            Spacer()

            hFloatingTextField(
                masking: Masking(type: .digits),
                value: $vm.squareArea,
                equals: $vm.type,
                focusValue: .squareArea,
                placeholder: L10n.changeAddressNewLivingSpaceLabel
            )
        }
    }

    func numberOfCoinsuredField() -> some View {
        HStack(spacing: 0) {
            hFloatingTextField(
                masking: Masking(type: .digits),
                value: $vm.nbOfCoInsured,
                equals: $vm.type,
                focusValue: .squareArea,
                placeholder: L10n.changeAddressCoInsuredLabel
            )

            Spacer()

            Button {
                if let coinsured = Int(vm.nbOfCoInsured), coinsured > 0 {
                    if coinsured == 1 {
                        vm.nbOfCoInsured = ""
                    } else {
                        vm.nbOfCoInsured = "\(coinsured - 1)"
                    }
                }
            } label: {
                Image(uiImage: hCoreUIAssets.minusSmall.image)
                    .foregroundColor(
                        hGrayscaleColorNew.greyScale1000.opacity((Int(vm.nbOfCoInsured) ?? 0) == 0 ? 0.4 : 1)
                    )

            }
            .frame(width: 30, height: 60)

            Button {
                let conisured = Int(vm.nbOfCoInsured) ?? 0
                vm.nbOfCoInsured = "\(conisured + 1)"
            } label: {
                Image(uiImage: hCoreUIAssets.plusSmall.image)
                    .foregroundColor(hGrayscaleColorNew.greyScale1000)
                    .padding(.trailing, 16)
            }
            .frame(width: 30, height: 60)
        }
    }

    func accessDateField() -> some View {
        VStack {
            hText(L10n.changeAddressMovingDateLabel, style: .footnote)
                .foregroundColor(hGrayscaleColorNew.greyScale700)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
            HStack(alignment: .top) {
                hText(L10n.changeAddressSelectMovingDateLabel, style: .title3)
                    .foregroundColor(hGrayscaleColorNew.greyScale700)
                    .padding(.leading, 16)
                Spacer()
                Image(uiImage: hCoreUIAssets.chevronDown.image)
                    .foregroundColor(hGrayscaleColorNew.greyScale1000)
                    .padding(.trailing, 16)
            }
        }
        .onTapGesture {
            store.send(.navigation(action: .openDatePickerScreen))
        }
        .padding(.vertical, 11)
        .background(
            Squircle.default()
                .fill(hGrayscaleColorNew.greyScale100)
        )
        .onTapGesture {
            store.send(.navigation(action: .openDatePickerScreen))
            self.vm.type = nil
        }
    }
}

struct SelectAddress_Previews: PreviewProvider {
    static var previews: some View {
        MovingFlowSelectAddress()
    }
}

enum MovingFlowSelectAddressFieldType: hTextFieldFocusStateCompliant {
    static var last: MovingFlowSelectAddressFieldType {
        return MovingFlowSelectAddressFieldType.accessDate
    }

    var next: MovingFlowSelectAddressFieldType? {
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

enum FieldType {
    case address
    case postal
    case square
    case nbOfCoinsured
}

class MovingFlowViewModel: ObservableObject {
    @Published var type: MovingFlowSelectAddressFieldType?
    @Published var address: String = ""
    @Published var postalCode: String = ""
    @Published var squareArea: String = ""
    @Published var nbOfCoInsured: String = ""
    @Published var accessDate: String = ""
    @Published var selectedField: FieldType? = nil
}
