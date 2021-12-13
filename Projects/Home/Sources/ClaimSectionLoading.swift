import Combine
import Flow
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ClaimSectionLoading: View {

    @State
    var shouldPoll = false

    var store: HomeStore

    init() {
        let store: HomeStore = globalPresentableStoreContainer.get()
        self.store = store
    }

    @ViewBuilder
    func claimsSection(_ claims: [Claim]) -> some View {
        if claims.isEmpty {
            Spacer().frame(height: 40)
        } else if claims.count == 1, let claim = claims.first {
            ClaimStatus(claim: claim, store: store)
                .padding([.bottom, .top])
        } else {
            ClaimSection(claims: claims, store: store)
                .padding([.bottom, .top])
        }
    }

    var body: some View {

        PresentableStoreLens(
            HomeStore.self,
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
