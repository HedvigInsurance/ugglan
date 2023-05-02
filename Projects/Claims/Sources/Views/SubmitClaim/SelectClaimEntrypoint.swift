import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct SelectClaimEntrypoint: View {
    @PresentableStore var store: SubmitClaimStore
    public init() {
        store.send(.fetchClaimEntrypointsForSelection)
    }
    public var body: some View {
        LoadingViewWithContent(.fetchClaimEntrypoints) {
            PresentableStoreLens(
                SubmitClaimStore.self,
                getter: { state in
                    state.claimEntrypoints
                }
            ) { claimEntrypoint in
                hForm {
                    hSection(claimEntrypoint, id: \.id) { claimType in
                        hRow {
                            hText(claimType.displayName, style: .body)
                                .foregroundColor(hLabelColor.primary)
                        }
                        .onTap {
                            store.send(
                                .commonClaimOriginSelected(commonClaim: ClaimsOrigin.commonClaims(id: claimType.id))
                            )
                        }
                    }
                    .withHeader {
                        hText(L10n.claimTriagingTitle, style: .prominentTitle)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 30)
                    }
                }

            }
            .presentableStoreLensAnimation(.easeInOut)
        }
    }
}
