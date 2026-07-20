import AppStateContainer
import SwiftUI
import hCore

@MainActor
public struct ClaimsCard: View {
    @AppObservedObject var store: ClaimsStore

    public init() {}

    public var body: some View {
        VStack {
            if store.activeClaims.isEmpty {
                Spacer().frame(height: 40)
            } else if store.activeClaims.count == 1, let claim = store.activeClaims.first {
                ClaimStatusCard(claim: claim, enableTap: true)
                    .padding(.vertical)
            } else {
                ClaimSection(claims: $store.activeClaims)
                    .padding(.vertical)
            }
        }
        .task {
            while !Task.isCancelled {
                await store.fetchActiveClaims()
                try? await Task.sleep(for: .seconds(120))
            }
        }
    }
}
