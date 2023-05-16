import SwiftUI
import hCore
import hCoreUI

struct MovingFlowSelectAddress: View {
    @State var address: String = ""
    @State var postalCode: String = ""
    @State var squareArea: String = ""
    @State var nbOfCoInsured: Int?
    @State var accessDate: String = ""

    var body: some View {
        LoadingViewWithContent(.setMoveIntent) {
            hFormNew {
                hText(L10n.changeAddressEnterNewAddressTitle, style: .title1)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding([.top, .bottom], 100)

                addressField()
                postalAndSquareField()
                numberOfCoinsuredField()
                accessDateField()
            }
            .hFormAttachToBottom {
                hButton.LargeButtonFilled {
                    // send isSelected to SelectDate
                } content: {
                    hText(L10n.generalContinueButton, style: .body)
                        .foregroundColor(hLabelColor.primary).colorInvert()
                }
                .padding([.leading, .trailing], 16)
            }
        }
    }

    @ViewBuilder
    func addressField() -> some View {
        HStack {
            hTextFieldNew(
                masking: Masking(type: .none),
                value: $address,
                placeholder: L10n.changeAddressNewAddressLabel
            )
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
            hTextFieldNew(
                masking: Masking(type: .digits),
                value: $postalCode,
                placeholder: L10n.changeAddressNewPostalCodeLabel
            )
            .hTextFieldOptions([])
            .padding(.leading, 16)
            .padding([.top, .bottom], 21)
            .background(
                Squircle.default()
                    .fill(hGrayscaleColorNew.greyScale100)
            )
            .padding(.leading, 16)

            Spacer()

            hTextFieldNew(
                masking: Masking(type: .digits),
                value: $squareArea,
                placeholder: L10n.changeAddressNewLivingSpaceLabel
            )
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
            if let coinsured = nbOfCoInsured {
                hText(String(coinsured), style: .title3)
                    .foregroundColor(hGrayscaleColorNew.greyScale700)
                    .padding(.leading, 16)
            } else {
                hText(L10n.changeAddressCoInsuredLabel, style: .title3)
                    .foregroundColor(hGrayscaleColorNew.greyScale400)
                    .padding(.leading, 16)
            }

            Spacer()

            Image(uiImage: hCoreUIAssets.minusIcon.image)
                .foregroundColor(hGrayscaleColorNew.greyScale400)
                .padding(.trailing, 16)
                .onTapGesture {
                    if nbOfCoInsured != nil && (nbOfCoInsured ?? 0) > 0 {
                        nbOfCoInsured! -= 1
                    }
                }

            Image(uiImage: hCoreUIAssets.plusIcon.image)
                .foregroundColor(hGrayscaleColorNew.greyScale1000)
                .padding(.trailing, 16)
                .onTapGesture {
                    if let coinsured = nbOfCoInsured {
                        nbOfCoInsured! += 1
                    } else {
                        nbOfCoInsured = 1
                    }
                }
        }
        .padding([.top, .bottom], 21)
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
                    .onTapGesture {
                        //open date picker screen
                    }
            }
        }
        .padding([.top, .bottom], 11)
        .background(
            Squircle.default()
                .fill(hGrayscaleColorNew.greyScale100)
        )
        .padding([.leading, .trailing], 16)
    }

}

struct SelectAddress_Previews: PreviewProvider {
    static var previews: some View {
        MovingFlowSelectAddress()
    }
}
