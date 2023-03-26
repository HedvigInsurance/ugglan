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
                        state.newClaim
                    }
                ) { claim in
                    displayBrandAndModelField(claim: claim)
                    displayDateField(claim: claim)
                    displayPurchasePriceField(claim: claim)
                    displayDamageField(claim: claim)
                }
            }
            .hFormAttachToBottom {
                hButton.LargeButtonFilled {
                    store.send(.submitSingleItem(purchasePrice: Double(purchasePrice) ?? 0))
                } content: {
                    hText(L10n.generalContinueButton)
                }
                .padding([.leading, .trailing], 16)
            }
        }
    }

    @ViewBuilder func displayBrandAndModelField(claim: NewClaim) -> some View {

        if claim.listOfModels != nil || claim.listOfBrands != nil {

            hRow {
                HStack {
                    hText(L10n.singleItemInfoBrand)
                        .foregroundColor(hLabelColor.secondary)

                    Spacer()
                }
            }
            .withCustomAccessory {
                if claim.chosenModel != nil {
                    hText(claim.chosenModel?.displayName ?? "")
                        .foregroundColor(hLabelColor.primary)
                } else if claim.chosenBrand != nil {
                    hText(claim.chosenBrand?.displayName ?? "")
                        .foregroundColor(hLabelColor.primary)
                } else {
                    hText(L10n.Claim.Location.choose)
                        .foregroundColor(hLabelColor.placeholder)
                }
            }
            .onTap {
                store.send(.openBrandPicker)
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

    @ViewBuilder func displayDateField(claim: NewClaim) -> some View {

        hRow {
            HStack {
                hText(L10n.Claims.Item.Screen.Date.Of.Purchase.button)
                    .foregroundColor(hLabelColor.secondary)
                    .padding([.top, .bottom], 16)

                Spacer()
            }
        }
        .withCustomAccessory {
            if claim.dateOfPurchase != nil {

                hText(convertDateToString(date: claim.dateOfPurchase ?? Date()))
                    .foregroundColor(hLabelColor.primary)
            } else {
                Image(uiImage: hCoreUIAssets.calendar.image)
            }
        }
        .onTap {
            store.send(.openDatePicker)
        }
        .frame(height: 64)
        .background(hBackgroundColor.tertiary)
        .cornerRadius(.defaultCornerRadius)
        .padding(.leading, 16)
        .padding(.trailing, 16)
        .padding(.top, 20)
        .hShadow()
    }

    @ViewBuilder func displayDamageField(claim: NewClaim) -> some View {

        if claim.listOfDamage != nil {
            hRow {
                HStack {

                    hText(L10n.Claims.Item.Screen.Damage.button)
                        .foregroundColor(hLabelColor.secondary)

                    Spacer()

                }
            }
            .withCustomAccessory {
                if let chosenDamages = claim.getChoosenDamages() {
                    hText(chosenDamages).foregroundColor(hLabelColor.primary)
                } else {
                    hText(L10n.Claim.Location.choose).foregroundColor(hLabelColor.placeholder)
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
    }

    @ViewBuilder func displayPurchasePriceField(claim: NewClaim) -> some View {
        hRow {
            ZStack {
                HStack {
                    hText(L10n.Claims.Item.Screen.Purchase.Price.button)
                        .foregroundColor(hLabelColor.secondary)
                    Spacer()
                    hText(claim.prefferedCurrency ?? "")
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
