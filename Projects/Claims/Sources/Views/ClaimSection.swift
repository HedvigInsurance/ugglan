import Combine
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ClaimSection: View {
    var claims: [ClaimModel]

    @PresentableStore
    var store: ClaimsStore

    var tapAction: (ClaimModel) -> Void {
        return { claim in
            store.send(.openClaimDetails(claim: claim))
        }
    }

    var body: some View {
        hCarousel(
            spacing: 16,
            items: claims,
            tapAction: tapAction
        ) { claim in
            ClaimStatus(claim: claim, enableTap: true)
                .padding(.top)
                .padding(.bottom, 5)
        }
    }
}
