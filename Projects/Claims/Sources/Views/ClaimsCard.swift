import AppStateContainer
import SwiftUI
import hCore
import hCoreUI

@MainActor
public struct ClaimsCard: View {
    let allActiveClaims: [ClaimsStore.ActiveClaimType]

    public init(allActiveClaims: [ClaimsStore.ActiveClaimType]) {
        self.allActiveClaims = allActiveClaims
    }

    public var body: some View {
        if !allActiveClaims.isEmpty {
            hSection {
                VStack {
                    if allActiveClaims.count == 1, let claim = allActiveClaims.first {
                        ClaimStatusCard(claimType: claim, enableTap: true)
                    } else {
                        ClaimSection(claims: .constant(allActiveClaims))
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }
}
