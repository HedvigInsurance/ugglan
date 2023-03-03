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
            hRow {
                HStack {
                    hText(L10n.Claims.Item.Screen.Model.button)
                }
            }
            .onTap {
                store.send(.openModelPicker)
            }
            .frame(height: 64)
            .background(hBackgroundColor.tertiary)
            .cornerRadius(12)
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.top, 20)

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
            .frame(height: 64)
            .background(hBackgroundColor.tertiary)
            .cornerRadius(.defaultCornerRadius)
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.top, 20)

            hButton.SmallButtonText {
            } content: {
                HSsack {

                    /* TODO: FIX CURSOR */
                    hText(L10n.Claims.Item.Screen.Purchase.Price.button)
                    hTextField(masking: currencyMasking, value: $purchasePrice)
                        .multilineTextAlignment(.trailing)
                    hText(Localization.Locale.currentLocale.market.currencyCode)
                }
            }
            .frame(height: 64)
            .background(hBackgroundColor.tertiary)
            .cornerRadius(12)
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.top, 20)

            hRow {

                HStack {
                    hText(L10n.Claims.Item.Screen.Damage.button)
                }

            }
            .onTap {
                store.send(.openDamagePickerScreen)
            }
            .frame(height: 64)
            .background(hBackgroundColor.tertiary)
            .cornerRadius(12)
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.top, 20)
        }
        .hFormAttachToBottom {
            hButton.LargeButtonFilled {
                store.send(.openSummaryScreen)
            } content: {
                hText(L10n.generalContinueButton)
            }
            .padding([.leading, .trailing], 16)
        }
    }
}

struct SubmitClaimObjectInformation_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimObjectInformation()
    }
}
