import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimEditSummaryScreen: View {
    @PresentableStore var store: ClaimsStore

    public init() {}

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
                    .padding([.leading, .trailing], -16) /* TODO: Possible to make this better? */
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
                header: hText("Product info", style: .subheadline) /* TODO: Change Text */
                    .foregroundColor(hLabelColor.secondary)
            ) {
                hRow {
                    HStack {
                        hText(L10n.Claims.Item.Screen.Model.button)
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
                    HStack {
                        hText(L10n.Claims.Item.Screen.Purchase.Price.button)
                        Spacer()
                        hText("13 499 kr") /* TODO: ADD EDITTEXT */
                            .foregroundColor(hLabelColor.secondary)
                    }
                }

                hRow {
                    HStack {
                        hText("Damage") /* TODO: CHANGE THIS TO TEXTKEY */
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
