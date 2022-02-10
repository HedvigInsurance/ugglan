import Combine
import Flow
import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ClaimSectionLoading: View {

    @ViewBuilder
    public func claimsSection(_ claims: [Claim]) -> some View {
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

        PresentableStoreLens(
            ClaimsStore.self,
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
