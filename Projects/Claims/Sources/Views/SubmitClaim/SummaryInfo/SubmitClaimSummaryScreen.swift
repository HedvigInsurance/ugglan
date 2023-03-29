import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimSummaryScreen: View {
    @PresentableStore var store: ClaimsStore

    public init() {}

    public var body: some View {
        LoadingViewWithContent(.claimNextSummary) {

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
                        store.send(.claimNextSummary)
                    } content: {
                        hText(L10n.generalContinueButton)
                    }
                    .padding([.leading, .trailing], 16)
                }
            }
        }
    }

    @ViewBuilder func displayTitleField(claim: NewClaim) -> some View {

        hText(claim.problemTitle ?? "", style: .title3)
            .padding(.top, UIScreen.main.bounds.size.height / 5)
            .foregroundColor(hLabelColor.secondary)
    }

    @ViewBuilder func displayDateAndLocationOfOccurrenceField(claim: NewClaim) -> some View {
        HStack {
            Image(uiImage: hCoreUIAssets.calendar.image)
                .resizable()
                .frame(width: 12.0, height: 12.0)
                .foregroundColor(.secondary)
            hText(claim.dateOfOccurrence ?? "")
                .padding(.top, 1)
                .foregroundColor(.secondary)
        }

        HStack {
            Image(uiImage: hCoreUIAssets.location.image)
                .foregroundColor(hLabelColor.secondary)
            hText(claim.location?.displayValue ?? "")
                .padding(.top, 1)
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder func displayModelField(claim: NewClaim) -> some View {

        if claim.chosenModel != nil {
            hText(claim.chosenModel?.displayName ?? "")
                .padding(.top, 40)
                .foregroundColor(hLabelColor.primary)
        } else if claim.chosenBrand != nil {
            hText(claim.chosenBrand?.displayName ?? "")
                .padding(.top, 40)
                .foregroundColor(hLabelColor.primary)
        }
    }

    @ViewBuilder func displayDateOfPurchase(claim: NewClaim) -> some View {

        hText(
            L10n.summaryPurchaseDescription(
                claim.dateOfPurchase?.localDateString ?? "",
                Int(claim.priceOfPurchase?.amount ?? 0)
            ) + " " + (claim.payoutAmount?.currencyCode ?? "")
        )
        .foregroundColor(hLabelColor.primary)
        .padding(.top, 1)
    }

    @ViewBuilder func displayDamageField(claim: NewClaim) -> some View {

        if let chosenDamages = claim.getChoosenDamages() {
            hText(L10n.summarySelectedProblemDescription(chosenDamages)).foregroundColor(hLabelColor.primary)
                .padding(.top, 1)
        } else {
            hText(L10n.Claim.Location.choose)
                .foregroundColor(hLabelColor.primary)
                .padding(.top, 1)
        }
    }
}

struct SubmitClaimSummaryScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimSummaryScreen()
    }
}
