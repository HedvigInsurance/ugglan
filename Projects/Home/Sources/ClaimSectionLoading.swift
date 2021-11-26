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

    @ViewBuilder
    func claimsSection(_ claims: [Claim]) -> some View {
        if claims.isEmpty {
            EmptyView()
        } else {
            ClaimSection(claims: claims)
        }
    }

    var body: some View {
        Poller(
            HomeStore.self,
            getter: { $0.claims ?? [] },
            fetchAction: .fetchClaims,
            shouldPoll: $shouldPoll
        ) { claims in
            claimsSection(claims)
        }
    }
}
