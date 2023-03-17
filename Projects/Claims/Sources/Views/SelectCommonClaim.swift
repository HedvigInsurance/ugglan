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
                state.entryPointCommonClaims ?? []
            },
            setter: { _ in
                .fetchCommonClaimsForSelection
            }
        ) { entryPointCommonClaims, _ in
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
}
