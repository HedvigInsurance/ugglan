import Combine
import SwiftUI
import hCore
import hCoreUI

struct ClaimSection: View {
    @Binding var claims: [ClaimModel]
    @StateObject var scrollVM: InfoCardScrollViewModel = .init(spacing: 16)
    @EnvironmentObject var homeRouter: Router

    var tapAction: (ClaimModel) -> Void {
        { claim in
            homeRouter.push(claim)
        }
    }

    var body: some View {
        InfoCardScrollView(
            items: $claims,
            vm: scrollVM,
            content: { claim in
                ClaimStatusCard(claim: claim, enableTap: true)
                    .padding(.top)
                    .padding(.bottom, 5)
            }
        )
    }
}
