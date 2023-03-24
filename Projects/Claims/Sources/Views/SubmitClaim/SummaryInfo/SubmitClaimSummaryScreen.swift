import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimSummaryScreen: View {
    @PresentableStore var store: ClaimsStore

    public init() {}

    public var body: some View {

        PresentableStoreLens(
            ClaimsStore.self,
            getter: { state in
                state.newClaim
            }
        ) { claim in

            hForm {
                VStack(alignment: .center) {

                    displayTitleField(claim: claim)
                    displayDateAndLocationOfOccurrenceField(claim: claim)
                    displayModelField(claim: claim)
                    displayDateOfPurchase(claim: claim)
                    displayDamageField(claim: claim)

                    //                    hButton.SmallButtonOutlined {
                    //                        store.send(.openSummaryEditScreen(context: ""))
                    //                    } content: {
                    //                        hText(L10n.Claims.Edit.button)
                    //                    }
                    //                    .padding(.top, 25)
                }
            }
            .hFormAttachToBottom {
                hButton.LargeButtonFilled {
                    store.send(.submitSummary)
                } content: {
                    hText(L10n.generalContinueButton)
                }
                .padding([.leading, .trailing], 16)
            }
        }
    }

    @ViewBuilder func displayModelField(claim: NewClaim) -> some View {

        if claim.chosenModel != nil {
            hText(claim.chosenModel?.displayName ?? "")
                .padding(.top, 40)
        } else if claim.chosenBrand != nil {
            hText(claim.chosenBrand?.displayName ?? "")
                .padding(.top, 40)
        }
    }

    @ViewBuilder func displayDateOfPurchase(claim: NewClaim) -> some View {

        hText(
            L10n.summaryPurchaseDescription(
                claim.dateOfPurchase?.localDateString ?? "",
                Int(claim.priceOfPurchase?.amount ?? 0)
            ) + " " + (claim.payoutAmount?.currencyCode ?? "")
        )
        .padding(.top, 2)
    }

    @ViewBuilder func displayDateAndLocationOfOccurrenceField(claim: NewClaim) -> some View {
        HStack {
            Image(uiImage: hCoreUIAssets.calendar.image)
                .resizable()
                .frame(width: 12.0, height: 12.0)
                .foregroundColor(.secondary)
            hText(claim.dateOfOccurrence ?? "")
                .padding(.top, 2)
                .foregroundColor(.secondary)
        }

        HStack {
            Image(uiImage: hCoreUIAssets.location.image)
                .foregroundColor(hLabelColor.secondary)
            hText(claim.location?.displayValue ?? "")
                .padding(.top, 2)
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder func displayTitleField(claim: NewClaim) -> some View {

        if claim.chosenModel != nil {
            hText(claim.chosenModel?.itemTypeID ?? "", style: .title3) /* TODO: CHANGE? */
                .padding(.top, UIScreen.main.bounds.size.height / 5)
        } else if claim.chosenBrand != nil {
            hText(claim.chosenBrand?.itemTypeId ?? "", style: .title3) /* TODO: CHANGE? */
                .padding(.top, UIScreen.main.bounds.size.height / 5)
        }
    }

    @ViewBuilder func displayDamageField(claim: NewClaim) -> some View {

        /* TODO: FIX */

        if claim.chosenDamages != nil {
            if claim.chosenDamages!.count <= 2 {
                ForEach(claim.chosenDamages ?? [], id: \.self) { damage in
                    hText(L10n.summarySelectedProblemDescription(damage.displayName))
                        .foregroundColor(hLabelColor.primary)
                        .padding(.top, 2)
                }
            } else {

                var counter = 0

                ForEach(claim.chosenDamages ?? [], id: \.self) { damage in
                    if counter < 2 {
                        hText(damage.displayName)
                            .foregroundColor(hLabelColor.primary)
                    }
                    let _ = counter += 1
                }
                hText("...")
                    .foregroundColor(hLabelColor.primary)
            }
        } else {
            hText(L10n.Claim.Location.choose)
                .foregroundColor(hLabelColor.primary)
        }
    }
}

struct SubmitClaimSummaryScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimSummaryScreen()
    }
}
