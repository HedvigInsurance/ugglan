import AppStateContainer
import SwiftUI
import hCore

@MainActor
public struct ClaimsCard: View {
    @AppObservedObject var store: ClaimsStore

    public init() {}

    public var body: some View {
        VStack {
            if !store.allActiveClaims.isEmpty {
                if store.allActiveClaims.count == 1, let claim = store.allActiveClaims.first {
                    ClaimStatusCard(claimType: claim, enableTap: true)
                } else {
                    ClaimSection(claims: $store.allActiveClaims)
                }
            }
        }
        .hWithoutDivider
        .task {
            while !Task.isCancelled {
                await store.fetchActiveClaims()
                await store.fetchClaimInProgress()
                try? await Task.sleep(for: .seconds(120))
            }
        }
    }
}
