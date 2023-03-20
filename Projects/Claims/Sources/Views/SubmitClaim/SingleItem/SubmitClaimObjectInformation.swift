import Combine
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

            PresentableStoreLens(
                ClaimsStore.self,
                getter: { state in
                    state.newClaims
                }
            ) { claim in

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
                    } else {
                        hText(L10n.Claim.Location.choose)
                            .foregroundColor(hLabelColor.primary)
                    }
                }
                .onTap {
                    store.send(.openModelPicker)
                }
            }
            .frame(height: 64)
            .background(hBackgroundColor.tertiary)
            .cornerRadius(12)
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.top, 20)
            .hShadow()

            PresentableStoreLens(
                ClaimsStore.self,
                getter: { state in
                    state.newClaims
                }
            ) { claim in

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
            .cornerRadius(12)
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .padding(.top, 20)
            .hShadow()

            PresentableStoreLens(
                ClaimsStore.self,
                getter: { state in
                    state.newClaims
                }
            ) { claim in

                hRow {
                    HStack {

                        hText(L10n.Claims.Item.Screen.Damage.button)
                            .foregroundColor(hLabelColor.secondary)

                        Spacer()

                    }
                }
                .withCustomAccessory {
                    if claim.chosenDamages != nil {

                        if claim.chosenDamages!.count <= 2 {
                            ForEach(claim.chosenDamages ?? [], id: \.self) { element in
                                hText(" " + element.displayValue)
                                    .foregroundColor(hLabelColor.primary)
                            }
                        } else {

                            //                            let arraySlice = claim.chosenDamages?.prefix(2)
                            //                            let damagesToShow = Array(arrayLiteral: arraySlice)

                            //                            var test2 = claim.chosenDamages[0..<1]

                            //                            ForEach(arraySlice , id: \.self) { element in
                            //////                                hText(" " + element.displayValue)
                            ////                                hText("" + element)
                            //////                                        .foregroundColor(hLabelColor.primary)
                            //                            }
                            hText("...")
                        }
                    } else {
                        hText(L10n.Claim.Location.choose)
                            .foregroundColor(hLabelColor.primary)

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
        .hFormAttachToBottom {
            hButton.LargeButtonFilled {
                store.send(.submitSingleItem(purchasePrice: Double(purchasePrice) ?? 0))
            } content: {
                hText(L10n.generalContinueButton)
            }
            .padding([.leading, .trailing], 16)
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
        SubmitClaimObjectInformation()
    }
}
