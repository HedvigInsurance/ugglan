import Combine
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ClaimSectionLoading: View {
    var body: some View {
        PresentableStoreLens(
            HomeStore.self,
            getter: { state in
                state.claims ?? []
            }
        ) { claims in
            if claims.isEmpty {
                EmptyView()
            } else {
                ClaimSection(claims: claims)
            }
        }
    }
}
