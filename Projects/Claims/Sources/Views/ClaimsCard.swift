import AppStateContainer
import SwiftUI
import hCore

@MainActor
public struct ClaimsCard: View {
    @AppObservedObject var store: ClaimsStore

    public init() {}

    public var body: some View {
        VStack {
            if store.allActiveClaims.isEmpty {
                Spacer().frame(height: 40)
            } else if store.allActiveClaims.count == 1, let claim = store.allActiveClaims.first {
                ClaimStatusCard(claimType: claim, enableTap: true)
                    .padding(.vertical)
            } else {
                ClaimSection(claims: $store.allActiveClaims)
                    .padding(.vertical)
            }
        }
        .task {
            while !Task.isCancelled {
                await store.fetchActiveClaims()
                await store.fetchClaimInProgress()
                try? await Task.sleep(for: .seconds(120))
            }
        }
    }
}
