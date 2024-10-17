import Combine
import Home
import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ClaimSection: View {
    @Binding var claims: [ClaimModel]
    @StateObject var scrollVM: InfoCardScrollViewModel = .init(spacing: 16)
    @PresentableStore var store: ClaimsStore
    @EnvironmentObject var homeRouter: Router

    var tapAction: (ClaimModel) -> Void {
        return { claim in
            homeRouter.push(claim)
        }
    }

    var body: some View {
        InfoCardScrollView(
            items: $claims,
            vm: scrollVM,
            content: { claim in
                ClaimStatus(claim: claim, enableTap: true)
                    .padding(.top)
                    .padding(.bottom, 5)
            }
        )
    }
}
