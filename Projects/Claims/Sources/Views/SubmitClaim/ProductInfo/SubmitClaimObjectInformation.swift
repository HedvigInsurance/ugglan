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
            /* TODO - SHOW ONLY IF PHONE */
            hRow {
                HStack {
                    hText(L10n.Claims.Item.Screen.Model.button)
                        .foregroundColor(hLabelColor.secondary)
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
            .hShadow()

            hButton.SmallButtonText {
                store.send(.openDatePicker)
            } content: {
                HStack(spacing: 0) {
                    hText(L10n.Claims.Item.Screen.Date.Of.Purchase.button)
                        .foregroundColor(hLabelColor.secondary)
                        .padding([.top, .bottom], 16)

                    Spacer()

                    Image(uiImage: hCoreUIAssets.calendar.image)
                }
            }
            .frame(height: 64)
            .background(hBackgroundColor.tertiary)
            .cornerRadius(12)
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.top, 20)
            .hShadow()

            hRow {
                ZStack {
                    HStack {
                        hText(L10n.Claims.Item.Screen.Purchase.Price.button)
                            .foregroundColor(hLabelColor.secondary)
                        Spacer()
                        hText(Localization.Locale.currentLocale.market.currencyCode)
                    }

                    hTextField(masking: currencyMasking, value: $purchasePrice)
                        .keyboardType(.default)
                        .multilineTextAlignment(.trailing)
                        .padding(.trailing, 40)
                        .padding(.top, 8.0)
                        .border(.clear)
                }
            }
            .frame(height: 64)
            .background(hBackgroundColor.tertiary)
            .cornerRadius(12)
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.top, 20)
            .hShadow()

            hRow {
                HStack {
                    hText(L10n.Claims.Item.Screen.Damage.button)
                        .foregroundColor(hLabelColor.secondary)
                }
            }
            .onTap {
                store.send(.openDamagePickerScreen)
            }
            .frame(height: 64)
            .background(hBackgroundColor.tertiary)
            .cornerRadius(.defaultCornerRadius)
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.top, 20)
            .hShadow()
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
