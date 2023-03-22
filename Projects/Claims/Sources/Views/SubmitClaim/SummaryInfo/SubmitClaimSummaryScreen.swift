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
                VStack(spacing: 0) {
                    hText("Broken phone", style: .title3) /* TODO: CHANGE */
                        .padding(.top, UIScreen.main.bounds.size.height / 5)

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

                    if claim.chosenModel != nil {
                        hText(claim.chosenModel?.displayName ?? "")
                            .padding(.top, 40)
                    } else {
                        hText(claim.chosenBrand?.displayName ?? "")
                            .padding(.top, 40)
                    }
                    hText(
                        L10n.summaryPurchaseDescription(
                            claim.dateOfPurchase?.localDateString ?? "",
                            Int(claim.priceOfPurchase ?? 0)
                        )
                    )
                    .padding(.top, 2)

                    ForEach(claim.chosenDamages ?? [], id: \.self) { damage in
                        hText(L10n.summarySelectedProblemDescription(damage.displayName))
                            .padding(.top, 2)
                    }

                    hButton.SmallButtonOutlined {
                        //                        store.send(.openSummaryEditScreencontext: String)
                    } content: {
                        hText(L10n.Claims.Edit.button)
                    }
                    .padding(.top, 25)
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
}

struct SubmitClaimSummaryScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimSummaryScreen()
    }
}
