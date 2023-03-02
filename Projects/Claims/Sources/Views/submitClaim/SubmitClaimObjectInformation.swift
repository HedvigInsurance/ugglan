import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimObjectInformation: View {
    @PresentableStore var store: ClaimsStore
    @State var purchasePrice: String

    public init() {
        purchasePrice = ""
    }

    var currencyMasking: Masking {
        Masking(type: .digits)
    }

    public var body: some View {
        hForm {

            hButton.SmallButtonText {
                store.send(.openDatePicker)
            } content: {

                HStack(spacing: 0) {
                    hText(L10n.Claims.Item.Screen.Date.Of.Purchase.button)
                        .padding([.top, .bottom], 16)

                    Spacer()

                    Image(uiImage: hCoreUIAssets.calendar.image)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(hBackgroundColor.tertiary)
            .cornerRadius(12)
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.top, 20)

            hButton.SmallButtonText {
                store.send(.openLocation)
            } content: {

                HStack(spacing: 0) {
                    hText("Typ av skada")
                        .padding([.top, .bottom], 16)

                    Spacer()

                    hText(L10n.Claim.Location.choose)
                }
                .onTapGesture {
                    //go to picker screen
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(hBackgroundColor.tertiary)
            .cornerRadius(12)
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.top, 20)

            /*TODO: ADD SO THAT YOU CAN CLICK ON THE WHOLE BUTTON AND WRITE*/
            hButton.SmallButtonText {
            } content: {
                HStack {
                    hText(L10n.Claims.Item.Screen.Date.Of.Purchase.button)
                    hTextField(masking: currencyMasking, value: $purchasePrice)
                        .contentShape(Rectangle())
                    hText(Localization.Locale.currentLocale.market.currencyCode)
                }

            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(hBackgroundColor.tertiary)
            .cornerRadius(12)
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.top, 20)
        }
    }
}

struct SubmitClaimObjectInformation_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimObjectInformation()
    }
}
