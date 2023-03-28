import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct SelectCommonClaim: View {
    @PresentableStore var store: ClaimsStore
    public init() {}
    public var body: some View {
        PresentableStoreLens(
            ClaimsStore.self,
            getter: { state in
                state.entryPointCommonClaims
            }
        ) { entryPointCommonClaims in
            switch entryPointCommonClaims {
            case .loading:
                ActivityIndicator(style: .large)
            case let .error(message):
                RetryView(title: message, retryTitle: L10n.generalRetry) {
                    store.send(.fetchCommonClaimsForSelection)
                }
                .padding(16)
            case let .success(entryPointCommonClaims):
                hForm {
                    hSection {
                        ForEach(entryPointCommonClaims, id: \.id) { claimType in
                            hRow {
                                hText(claimType.displayName)
                            }
                            .onTap {
                                store.send(
                                    .commonClaimOriginSelected(commonClaim: ClaimsOrigin.commonClaims(id: claimType.id))
                                )
                            }
                        }
                    }
                    .withHeader {
                        hText(L10n.claimTriagingTitle, style: .prominentTitle)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
        }
        .presentableStoreLensAnimation(.easeInOut)
    }
}
