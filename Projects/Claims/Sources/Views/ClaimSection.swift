import Combine
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ClaimSection: View {
    internal init(
        claims: [Claim]
    ) {
        state = ClaimSectionState(claims: claims)
    }

    @ObservedObject
    var state: ClaimSectionState

    @PresentableStore
    var store: ClaimsStore
    
    var tapAction: (Claim) -> Void {
        return { claim in
            store.send(.openClaimDetails(claim: claim))
        }
    }
    
    var body: some View {
        hCarousel(
            spacing: 16,
            items: state.claims,
            tapAction: tapAction
        ) { claim in
            VStack {
                ClaimStatus(claim: claim)
                    .padding(.top)
                    .padding(.bottom, 5)
            }
        }
    }
}
