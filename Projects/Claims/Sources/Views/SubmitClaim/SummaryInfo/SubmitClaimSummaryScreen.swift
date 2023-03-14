import SwiftUI
import hCore
import hCoreUI

public struct SubmitClaimSummaryScreen: View {
    @PresentableStore var store: ClaimsStore

    public init() {}

    public var body: some View {

        hForm {
            VStack(spacing: 0) {
                hText("Broken phone", style: .title3) /* TODO: CHANGE */
                    .padding(.top, UIScreen.main.bounds.size.height / 5)

                HStack {
                    Image(uiImage: hCoreUIAssets.calendar.image)
                        .resizable()
                        .frame(width: 12.0, height: 12.0)
                        .foregroundColor(.secondary)
                    hText("19 Apr 2022") /* TODO: CHANGE */
                        .padding(.top, 2)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Image(uiImage: hCoreUIAssets.location.image)
                        .foregroundColor(hLabelColor.secondary)
                    hText("Sweden") /* TODO: CHANGE */
                        .padding(.top, 2)
                        .foregroundColor(.secondary)
                }

                hText("iPhone 13 128GB") /* TODO: CHANGE */
                    .padding(.top, 40)
                hText(L10n.summaryPurchaseDescription("Jan. 2022", 13499)) /* TODO: CHANGE */
                    .padding(.top, 2)
                hText(L10n.summarySelectedProblemDescription("Only front")) /* TODO: CHANGE */
                    .padding(.top, 2)

                hButton.SmallButtonOutlined {
                    store.send(.openSummaryEditScreen)
                } content: {
                    hText(L10n.Claims.Edit.button)
                }
                .padding(.top, 25)
            }
        }
        .hFormAttachToBottom {
            hButton.LargeButtonFilled {
                store.send(.openCheckoutNoRepairScreen)
            } content: {
                hText(L10n.generalContinueButton)
            }
            .padding([.leading, .trailing], 16)
        }
    }
}

struct SubmitClaimSummaryScreen_Previews: PreviewProvider {
    static var previews: some View {
        SubmitClaimSummaryScreen()
    }
}
