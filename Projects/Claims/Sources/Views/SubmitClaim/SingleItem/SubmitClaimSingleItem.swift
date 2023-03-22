import Combine
import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimSingleItem: View {
    @PresentableStore var store: ClaimsStore
    @State var purchasePrice: String = ""

    public init() {}

    public var body: some View {

        hForm {
            PresentableStoreLens(
                ClaimsStore.self,
                getter: { state in
                    state.newClaim
                }
            ) { claim in

                if claim.listOfModels != nil || claim.listOfBrands != nil {  //nil or empty?

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
                                .foregroundColor(hLabelColor.primary)
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

                hRow {
                    HStack {
                        hText(L10n.Claims.Item.Screen.Date.Of.Purchase.button)
                            .foregroundColor(hLabelColor.secondary)
                            .padding([.top, .bottom], 16)

                        Spacer()
                    }
                }
                //                .withCustomAccessory {
                //                    if claim.dateOfPurchase != nil {
                //
                //                        hText(convertDateToString(date: claim.dateOfPurchase ?? Date()))
                //                            .foregroundColor(hLabelColor.primary)
                //                    } else {
                //                        Image(uiImage: hCoreUIAssets.calendar.image)
                //                    }
                //                }
                .onTap {
                    store.send(.openDatePicker)
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
                    .frame(height: 64)
                    .background(hBackgroundColor.tertiary)
                    .cornerRadius(12)
                    .padding(.leading, 16)
                    .padding(.trailing, 16)
                    .padding(.top, 20)
                    .hShadow()
                }

                //                    if claim.listOfDamages != nil {
                //
                //                        hRow {
                //                            HStack {
                //
                //                                hText(L10n.Claims.Item.Screen.Damage.button)
                //                                    .foregroundColor(hLabelColor.secondary)
                //
                //                                Spacer()
                //
                //                            }
                //                        }
                //                        .withCustomAccessory {
                //                            if claim.chosenDamages != nil {
                //
                //                                if claim.chosenDamages!.count <= 2 {
                //                                    ForEach(claim.chosenDamages ?? [], id: \.self) { element in
                //                                        hText(element.displayName)
                //                                            .foregroundColor(hLabelColor.primary)
                //                                    }
                //                                } else {
                //
                //                                    var counter = 0
                //
                //                                    ForEach(claim.chosenDamages ?? [], id: \.self) { element in
                //                                        if counter < 2 {
                //                                            hText(element.displayName)
                //                                                .foregroundColor(hLabelColor.primary)
                //                                        }
                //                                        let _ = counter += 1
                //                                    }
                //                                    hText("...")
                //                                        .foregroundColor(hLabelColor.primary)
                //                                }
                //                            } else {
                //                                hText(L10n.Claim.Location.choose)
                //                                    .foregroundColor(hLabelColor.primary)
                //                            }
                //                        }
                //                        .onTap {
                //                            store.send(.openDamagePickerScreen)
                //                        }
                //                        .frame(height: 64)
                //                        .background(hBackgroundColor.tertiary)
                //                        .cornerRadius(.defaultCornerRadius)
                //                        .padding(.leading, 16)
                //                        .padding(.trailing, 16)
                //                        .padding(.top, 20)
                //                        .hShadow()
                //                    }
                //                }
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
        SubmitClaimSingleItem()
    }
}
