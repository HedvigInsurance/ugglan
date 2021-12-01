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
            ClaimStatus(claim: claim)
                .padding([.bottom, .top])
        } else {
            ClaimSection(claims: claims)
                .padding([.bottom, .top])
        }
    }

    var body: some View {
        VStack {
            if shouldPoll {
                Poller(
                    HomeStore.self,
                    getter: { $0.claims ?? [] },
                    fetchAction: .fetchClaims,
                    shouldPoll: $shouldPoll
                ) { claims in
                    claimsSection(claims)
                }
            } else {
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
        .onReceive(store.actionSignal.filter(predicate: { $0 == .setClaimsNeedsUpdating }).publisher) { updateClaims in
            shouldPoll = true
        }
    }
}
