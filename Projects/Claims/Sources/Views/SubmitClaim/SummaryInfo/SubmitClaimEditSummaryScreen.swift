import Combine
import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimEditSummaryScreen: View {
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

            hSection(
                header: hText(L10n.Claims.Incident.Screen.header, style: .subheadline)
                    .foregroundColor(hLabelColor.secondary)
            ) {
                hRow {
                    hButton.SmallButtonText {
                        store.send(.openDatePicker)
                    } content: {
                        HStack(spacing: 0) {
                            hText(L10n.Claims.Item.Screen.Date.Of.Incident.button)
                                .foregroundColor(hLabelColor.primary)
                            Spacer()

                            HStack(spacing: 0) {
                                hText("19 Apr 2022")
                                    .foregroundColor(hLabelColor.primary).colorScheme(.light)
                                    .padding([.top, .bottom], 11)
                                    .padding([.trailing, .leading], 12)
                            }
                            .background(hGrayscaleColor.one)
                            .cornerRadius(.defaultCornerRadius)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding([.leading, .trailing], -16)
                    .padding([.bottom, .top], -11)
                }

                hRow {
                    HStack {
                        hText(L10n.Claims.Location.Screen.title)
                            .foregroundColor(hLabelColor.primary)
                        Spacer()
                        hText("Sweden")
                            .foregroundColor(hLabelColor.secondary)
                    }
                }
                .onTap {
                    store.send(.openLocationPicker)
                }
            }

            hSection(
                header: hText(L10n.Claims.Item.Screen.title, style: .subheadline)
                    .foregroundColor(hLabelColor.secondary)
            ) {
                hRow {
                    HStack {
                        hText(L10n.Claims.Item.Screen.Model.button)
                            .foregroundColor(hLabelColor.primary)
                        Spacer()
                        hText("iPhone 13 128GB")
                            .foregroundColor(hLabelColor.secondary)
                    }
                }
                .onTap {
                    store.send(.openModelPicker)
                }

                hRow {
                    hButton.SmallButtonText {
                        store.send(.openDatePicker)
                    } content: {
                        HStack(spacing: 0) {
                            hText(L10n.Claims.Item.Screen.Date.Of.Purchase.button)
                                .foregroundColor(hLabelColor.primary)
                            Spacer()

                            HStack(spacing: 0) {
                                hText("Jan 2022")
                                    .foregroundColor(hLabelColor.primary).colorScheme(.light)
                                    .padding([.top, .bottom], 11)
                                    .padding([.trailing, .leading], 12)
                            }
                            .background(hGrayscaleColor.one)
                            .cornerRadius(.defaultCornerRadius)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding([.leading, .trailing], -16) /* TODO: Possible to make this better? */
                    .padding([.bottom, .top], -11)
                }

                hRow {
                    ZStack {
                        HStack {
                            hText(L10n.Claims.Item.Screen.Purchase.Price.button)
                                .foregroundColor(hLabelColor.primary)
                            Spacer()
                            hText(Localization.Locale.currentLocale.market.currencyCode)
                                .foregroundColor(hLabelColor.secondary)
                        }

                        TextField("", text: $purchasePrice)
                            .multilineTextAlignment(.trailing)
                            .padding(.trailing, 40)
                            .keyboardType(.numberPad)
                            .onReceive(Just(purchasePrice)) { newValue in
                                let filteredNumbers = newValue.filter { "0123456789".contains($0) }
                                if filteredNumbers != newValue {
                                    self.purchasePrice = filteredNumbers
                                }
                            }
                    }
                }

                hRow {
                    HStack {
                        hText(L10n.Claims.Item.Screen.Damage.button)
                            .foregroundColor(hLabelColor.primary)
                        Spacer()
                        hText("Only front")
                            .foregroundColor(hLabelColor.secondary)
                    }
                }
                .onTap {
                    store.send(.openDamagePickerScreen)
                }
            }
        }
        .hFormAttachToBottom {
            hButton.LargeButtonFilled {
                store.send(.dissmissNewClaimFlow)
            } content: {
                hText(L10n.generalSaveButton)
            }
            .padding([.leading, .trailing], 16)
        }
    }
}

struct SubmitClaimEditSummaryScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimEditSummaryScreen()
    }
}
