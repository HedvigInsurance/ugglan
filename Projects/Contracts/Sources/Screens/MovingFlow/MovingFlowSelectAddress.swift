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

    var body: some View {
        LoadingViewWithContent(.setMoveIntent) {
            hFormNew {
                hText(L10n.changeAddressEnterNewAddressTitle, style: .title1)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 64)
                    .padding(.top, 56)

                addressField()
                postalAndSquareField()
                numberOfCoinsuredField()
                accessDateField()
            }
            .hFormAttachToBottomNew {
                hButton.LargeButtonFilled {
                    store.send(.navigationActionMovingFlow(action: .openConfirmScreen))
                } content: {
                    hText(L10n.generalContinueButton, style: .body)
                        .foregroundColor(hLabelColor.primary).colorInvert()
                }
                .padding([.leading, .trailing], 16)
                .padding(.bottom, 8)
            }
        }
        .addOnDone(binding: $type, itemsToShowDone: [.postalCode, .squareArea, .nbOfCoInsured]) {
            type = type?.next
        }
        .onChange(of: type) { newValue in
            if newValue == nil {
                UIApplication.dismissKeyboard()
            } else if newValue == .accessDate {
                UIApplication.dismissKeyboard()
                store.send(.navigationActionMovingFlow(action: .openDatePickerScreen))
            }
        }
        .dismissKeyboard()
    }

    @ViewBuilder
    func addressField() -> some View {
        HStack {
            hTextField(
                masking: Masking(type: .address),
                value: $address
            )
            .focused($type, equals: .address)
            .hTextFieldOptions([])
            .padding(.leading, 16)
            Spacer()
        }
        .padding([.top, .bottom], 21)
        .background(
            Squircle.default()
                .fill(hGrayscaleColorNew.greyScale100)
        )
        .padding([.leading, .trailing], 16)
    }

    @ViewBuilder
    func postalAndSquareField() -> some View {
        HStack(spacing: 0) {
            hTextField(
                masking: Masking(type: .postalCode),
                value: $postalCode,
                placeholder: L10n.changeAddressNewPostalCodeLabel
            )
            .focused($type, equals: .postalCode)
            .hTextFieldOptions([])
            .padding(.leading, 16)
            .padding([.top, .bottom], 21)
            .background(
                Squircle.default()
                    .fill(hGrayscaleColorNew.greyScale100)
            )
            .padding(.leading, 16)
            Spacer()

            hTextField(
                masking: Masking(type: .digits),
                value: $squareArea,
                placeholder: L10n.changeAddressNewLivingSpaceLabel
            )
            .focused($type, equals: .squareArea)
            .hTextFieldOptions([])
            .padding(.leading, 16)
            .padding([.top, .bottom], 21)
            .background(
                Squircle.default()
                    .fill(hGrayscaleColorNew.greyScale100)
            )
            .padding(.trailing, 16)
        }
    }

    @ViewBuilder
    func numberOfCoinsuredField() -> some View {
        HStack(spacing: 0) {
            hTextField(
                masking: Masking(type: .digits),
                value: $nbOfCoInsured,
                placeholder: L10n.changeAddressCoInsuredLabel
            )
            .focused($type, equals: .nbOfCoInsured)
            .hTextFieldOptions([])
            .padding(.leading, 16)
            .background(
                Squircle.default()
                    .fill(hGrayscaleColorNew.greyScale100)
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
                Image(uiImage: hCoreUIAssets.minusIcon.image)
                    .foregroundColor(hGrayscaleColorNew.greyScale1000.opacity((Int(nbOfCoInsured) ?? 0) == 0 ? 0.4 : 1))

            }
            .frame(width: 30, height: 60)

            Button {
                let conisured = Int(nbOfCoInsured) ?? 0
                nbOfCoInsured = "\(conisured + 1)"
            } label: {
                Image(uiImage: hCoreUIAssets.plusIcon.image)
                    .foregroundColor(hGrayscaleColorNew.greyScale1000)
            }
            .frame(width: 30, height: 60)

        }
        .background(
            Squircle.default()
                .fill(hGrayscaleColorNew.greyScale100)
        )
        .padding([.leading, .trailing], 16)
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
        .padding([.top, .bottom], 11)
        .background(
            Squircle.default()
                .fill(hGrayscaleColorNew.greyScale100)
        )
        .padding([.leading, .trailing], 16)
        .onTapGesture {
            store.send(.navigationActionMovingFlow(action: .openDatePickerScreen))
            self.type = nil
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
