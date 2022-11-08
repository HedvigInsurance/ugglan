import Combine
import Flow
import Foundation
import Presentation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI
import hGraphQL

struct ClaimSectionLoading: View {
    @PresentableStore var store: ClaimsStore

    @ViewBuilder
    public func claimsSection(_ claims: [Claim]) -> some View {
        VStack {
            if claims.isEmpty {
                Spacer().frame(height: 40)
            } else if claims.count == 1, let claim = claims.first {
                ClaimStatus(claim: claim)
                    .padding([.bottom, .top])
            } else {
                ClaimSection(claims: claims)
                    .padding([.bottom, .top])
            }

            startClaimsButton(claims)
                .padding(.bottom, 16)

            HowClaimsWorkButton()
        }
    }

    @ViewBuilder
    public func startClaimsButton(_ claims: [Claim]) -> some View {
        if claims.count > 0 {
            hButton.LargeButtonOutlined {
                hAnalyticsEvent.beginClaim(screen: .home).send()
                store.send(.submitNewClaim)
            } content: {
                L10n.Home.OpenClaim.startNewClaimButton.hText()
            }
        } else {
            hButton.LargeButtonFilled {
                hAnalyticsEvent.beginClaim(screen: .home).send()
                store.send(.submitNewClaim)
            } content: {
                hText(L10n.HomeTab.claimButtonText)
            }
        }
    }

    var body: some View {

        PresentableStoreLens(
            ClaimsStore.self,
            getter: { state in
                state.claims ?? []
            },
            setter: { _ in
                .fetchClaims
            }
        ) { claims, _ in
            claimsSection(claims)
        }
    }
}
