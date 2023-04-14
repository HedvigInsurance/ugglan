import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct SelectCommonClaim: View {
    @PresentableStore var store: ClaimsStore
    public init() {
        store.send(.fetchCommonClaimsForSelection)
    }
    public var body: some View {
        LoadingViewWithContent(.fetchCommonClaims) {
            PresentableStoreLens(
                ClaimsStore.self,
                getter: { state in
                    state.entryPointCommonClaims
                }
            ) { entryPointCommonClaims in
                hForm {
                    hSection(entryPointCommonClaims, id: \.id) { claimType in
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
