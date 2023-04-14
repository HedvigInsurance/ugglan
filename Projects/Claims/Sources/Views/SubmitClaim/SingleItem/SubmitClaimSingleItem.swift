import Combine
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct SubmitClaimSingleItem: View {
    @PresentableStore var store: ClaimsStore
    @State var purchasePrice: String = ""

    public init() {}

    public var body: some View {
        LoadingViewWithContent(.postSingleItem) {
            hForm {
                PresentableStoreLens(
                    ClaimsStore.self,
                    getter: { state in
                        state.singleItemStep
                    }
                ) { singleItemStep in
                    displayBrandAndModelField(singleItemStep: singleItemStep)
                    displayDateField(claim: singleItemStep)
                    displayPurchasePriceField(claim: singleItemStep)
                    displayDamageField(claim: singleItemStep)
                }
            }
            .hFormAttachToBottom {
                hButton.LargeButtonFilled {
                    store.send(.claimNextSingleItem(purchasePrice: Double(purchasePrice)))
                    UIApplication.dismissKeyboard()
                } content: {
                    hText(L10n.generalContinueButton)
                }
                .padding([.leading, .trailing], 16)
            }
        }
    }

    @ViewBuilder func displayBrandAndModelField(singleItemStep: FlowClamSingleItemStepModel?) -> some View {

        if (singleItemStep?.availableItemModelOptions.count) ?? 0 > 0
            || (singleItemStep?.availableItemBrandOptions.count) ?? 0 > 0
        {

            hSection {
                hRow {
                    HStack {
                        hText(L10n.singleItemInfoBrand)
                            .foregroundColor(hLabelColor.primary)

                        Spacer()
                    }
                }
                .withCustomAccessory {
                    if let brandName = singleItemStep?.getBrandOrModelName() {
                        hText(brandName)
                            .foregroundColor(hLabelColor.secondary)
                    } else {
                        hText(L10n.Claim.Location.choose)
                            .foregroundColor(hLabelColor.placeholder)
                    }
                }
                .onTap {
                    store.send(.navigationAction(action: .openBrandPicker))
                }
            }

        }
    }

    @ViewBuilder func displayDateField(claim: FlowClamSingleItemStepModel?) -> some View {
        hSection {
            hRow {
                hText(L10n.Claims.Item.Screen.Date.Of.Purchase.button)
                    .foregroundColor(hLabelColor.primary)
            }
            .withCustomAccessory {
                Spacer()

                Group {
                    if let purchaseDate = claim?.purchaseDate {
                        hText(purchaseDate)
                    } else {
                        Image(uiImage: hCoreUIAssets.calendar.image)
                            .renderingMode(.template)
                    }
                }
                .foregroundColor(hLabelColor.secondary)
            }
            .onTap {
                store.send(.navigationAction(action: .openDatePicker(type: .setDateOfPurchase)))
            }
        }
    }

    @ViewBuilder func displayDamageField(claim: FlowClamSingleItemStepModel?) -> some View {
        if !(claim?.availableItemProblems.isEmpty ?? true) {
            if (claim?.selectedItemProblems) != nil {
                hSection {
                    hRow {
                        hText(L10n.Claims.Item.Screen.Damage.button)
                            .foregroundColor(hLabelColor.primary)
                    }
                    .withCustomAccessory {
                        Spacer()

                        if let chosenDamages = claim?.getChoosenDamagesAsText() {
                            hText(chosenDamages).foregroundColor(hLabelColor.secondary)
                        } else {
                            hText(L10n.Claim.Location.choose).foregroundColor(hLabelColor.placeholder)
                        }
                    }
                    .onTap {
                        store.send(.navigationAction(action: .openDamagePickerScreen))
                    }
                }
            }
        }
    }

    @ViewBuilder func displayPurchasePriceField(claim: FlowClamSingleItemStepModel?) -> some View {
        hSection {
            hRow {
                hText(L10n.Claims.Item.Screen.Purchase.Price.button)
                    .foregroundColor(hLabelColor.primary)
            }
            .withCustomAccessory {
                Group {
                    hTextField(
                        masking: Masking(type: .digits),
                        value: $purchasePrice
                    )
                    .multilineTextAlignment(.trailing)
                    .hTextFieldOptions([])
                    Spacer()

                    if let preferredCurrency = claim?.prefferedCurrency {
                        let amount = MonetaryAmount(amount: 0.0, currency: preferredCurrency)
                        hText(amount.currencySymbol)
                    }
                }
                .foregroundColor(hLabelColor.secondary)
            }
        }
    }

    func convertDateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}

struct SubmitClaimObjectInformation_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimSingleItem()
    }
}
