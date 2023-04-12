import Combine
import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimSingleItem: View {
    @PresentableStore var store: ClaimsStore
    @State var purchasePrice: String = ""

    public init() {}

    public var body: some View {
        LoadingViewWithContent(.claimNextSingleItem(purchasePrice: Double(purchasePrice) ?? 0)) {
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
                    store.send(.claimNextSingleItem(purchasePrice: Double(purchasePrice) ?? 0))
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

            hRow {
                HStack {
                    hText(L10n.singleItemInfoBrand)
                        .foregroundColor(hLabelColor.secondary)

                    Spacer()
                }
            }
            .withCustomAccessory {
                if let brandName = singleItemStep?.getBrandOrModelName() {
                    hText(brandName)
                        .foregroundColor(hLabelColor.primary)
                } else {
                    hText(L10n.Claim.Location.choose)
                        .foregroundColor(hLabelColor.placeholder)
                }
            }
            .onTap {
                store.send(.navigationAction(action: .openBrandPicker))
            }
            .frame(height: 64)
            .background(hBackgroundColor.tertiary)
            .cornerRadius(12)
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.top, 20)
            .hShadow()
        }
    }

    @ViewBuilder func displayDateField(claim: FlowClamSingleItemStepModel?) -> some View {

        hRow {
            HStack {
                hText(L10n.Claims.Item.Screen.Date.Of.Purchase.button)
                    .foregroundColor(hLabelColor.secondary)
                    .padding([.top, .bottom], 16)

                Spacer()
            }
        }
        .withCustomAccessory {
            if let purchaseDate = claim?.purchaseDate {

                hText(purchaseDate)
                    .foregroundColor(hLabelColor.primary)
            } else {
                Image(uiImage: hCoreUIAssets.calendar.image)
            }
        }
        .onTap {
            store.send(.navigationAction(action: .openDatePicker(type: .setDateOfPurchase)))
        }
        .frame(height: 64)
        .background(hBackgroundColor.tertiary)
        .cornerRadius(.defaultCornerRadius)
        .padding(.leading, 16)
        .padding(.trailing, 16)
        .padding(.top, 20)
        .hShadow()
    }

    @ViewBuilder func displayDamageField(claim: FlowClamSingleItemStepModel?) -> some View {
        if !(claim?.availableItemProblems.isEmpty ?? true) {
            if (claim?.selectedItemProblems) != nil {
                hRow {
                    HStack {

                        hText(L10n.Claims.Item.Screen.Damage.button)
                            .foregroundColor(hLabelColor.secondary)

                        Spacer()

                    }
                }
                .withCustomAccessory {
                    if let chosenDamages = claim?.getChoosenDamagesAsText() {
                        hText(chosenDamages).foregroundColor(hLabelColor.primary)
                    } else {
                        hText(L10n.Claim.Location.choose).foregroundColor(hLabelColor.placeholder)
                    }
                }
                .onTap {
                    store.send(.navigationAction(action: .openDamagePickerScreen))
                }
                .frame(height: 64)
                .background(hBackgroundColor.tertiary)
                .cornerRadius(.defaultCornerRadius)
                .padding(.leading, 16)
                .padding(.trailing, 16)
                .padding(.top, 20)
                .hShadow()
            }
        }
    }

    @ViewBuilder func displayPurchasePriceField(claim: FlowClamSingleItemStepModel?) -> some View {
        hRow {
            ZStack {
                HStack {
                    hText(L10n.Claims.Item.Screen.Purchase.Price.button)
                        .foregroundColor(hLabelColor.secondary)
                    Spacer()
                    hText(claim?.prefferedCurrency ?? "")
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
        .frame(height: 64)
        .background(hBackgroundColor.tertiary)
        .cornerRadius(.defaultCornerRadius)
        .padding(.leading, 16)
        .padding(.trailing, 16)
        .padding(.top, 20)
        .hShadow()
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
