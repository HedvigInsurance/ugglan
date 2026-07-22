import Combine
import SwiftUI
import hCoreUI

struct ClaimSection: View {
    @Binding var claims: [ClaimsStore.ActiveClaimType]
    @StateObject var scrollVM: InfoCardScrollViewModel = .init(spacing: 16)

    var body: some View {
        InfoCardScrollView(
            items: $claims,
            vm: scrollVM,
            content: { claimType in
                ClaimStatusCard(claimType: claimType, enableTap: true)
                    .padding(.top)
                    .padding(.bottom, 5)
            }
        )
    }
}
