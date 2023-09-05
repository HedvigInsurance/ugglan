import SwiftUI
import hCore
import hCoreUI

struct MovingFlowSelectAddress: View {
    @PresentableStore var store: ContractStore
    @State var type: MovingFlowSelectAddressFieldType?
    @State var address: String = ""
    @State var postalCode: String = ""
    @State var squareArea: String = ""
    @State var nbOfCoInsured: String = ""
    @State var accessDate: String = ""
    @State var selectedField: FieldType? = nil

    var body: some View {
        //        LoadingViewWithContent(ContractStore.self, [.fetchMoveIntent]) {
        hForm {
            addressField()
            postalAndSquareField()
            numberOfCoinsuredField()
            accessDateField()
        }
        .hFormTitle(.standard, .title3, L10n.changeAddressEnterNewAddressTitle)
        .hFormAttachToBottom {
            hButton.LargeButtonPrimary {
                //                store.send(.navigationActionMovingFlow(action: .openConfirmScreen))
            } content: {
                hText(L10n.generalContinueButton, style: .body)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        //        }
        .onChange(of: type) { newValue in
            if newValue == nil {
                UIApplication.dismissKeyboard()
            } else if newValue == .accessDate {
                UIApplication.dismissKeyboard()
                //                store.send(.navigationActionMovingFlow(action: .openDatePickerScreen))
            }
        }
        .dismissKeyboard()
    }

    @ViewBuilder
    func addressField() -> some View {
        hSection {
            hFloatingTextField(
                masking: Masking(type: .address),
                value: $address,
                equals: $type,
                focusValue: .address
            )
        }
    }

    @ViewBuilder
    func postalAndSquareField() -> some View {

        hSection {
            HStack(spacing: 0) {

                hFloatingTextField(
                    masking: Masking(type: .postalCode),
                    value: $postalCode,
                    equals: $type,
                    focusValue: .postalCode,
                    placeholder: L10n.changeAddressNewPostalCodeLabel
                )

                Spacer()

                hFloatingTextField(
                    masking: Masking(type: .digits),
                    value: $squareArea,
                    equals: $type,
                    focusValue: .squareArea,
                    placeholder: L10n.changeAddressNewLivingSpaceLabel
                )
            }
        }
    }

    @ViewBuilder
    func numberOfCoinsuredField() -> some View {
        hSection {
            HStack(spacing: 0) {
                hFloatingTextField(
                    masking: Masking(type: .digits),
                    value: $nbOfCoInsured,
                    equals: $type,
                    focusValue: .squareArea,
                    placeholder: L10n.changeAddressCoInsuredLabel
                )

                Spacer()

                Button {
                    if let coinsured = Int(nbOfCoInsured), coinsured > 0 {
                        if coinsured == 1 {
                            nbOfCoInsured = ""
                        } else {
                            nbOfCoInsured = "\(coinsured - 1)"
                        }
                    }
                } label: {
                    Image(uiImage: hCoreUIAssets.minusSmall.image)
                        .foregroundColor(
                            hGrayscaleColorNew.greyScale1000.opacity((Int(nbOfCoInsured) ?? 0) == 0 ? 0.4 : 1)
                        )

                }
                .frame(width: 30, height: 60)

                Button {
                    let conisured = Int(nbOfCoInsured) ?? 0
                    nbOfCoInsured = "\(conisured + 1)"
                } label: {
                    Image(uiImage: hCoreUIAssets.plusSmall.image)
                        .foregroundColor(hGrayscaleColorNew.greyScale1000)
                        .padding(.trailing, 16)
                }
                .frame(width: 30, height: 60)
            }
        }
    }

    @ViewBuilder
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
            //            store.send(.navigationActionMovingFlow(action: .openDatePickerScreen))
        }
        .padding(.vertical, 11)
        .background(
            Squircle.default()
                .fill(hGrayscaleColorNew.greyScale100)
        )
        .padding(.horizontal, 16)
        .onTapGesture {
            //            store.send(.navigationActionMovingFlow(action: .openDatePickerScreen))
            self.type = nil
        }
    }

    @hColorBuilder
    func textFieldColor(text: FieldType) -> some hColor {
        if text == selectedField {
            hGreenColorNew.green100
        } else {
            hGrayscaleColorNew.greyScale100
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
