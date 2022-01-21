import Combine
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ClaimSection: View {
    internal init(
        claims: [Claim]
    ) {
        state = ClaimSectionState(claims: claims)
    }

    @ObservedObject
    var state: ClaimSectionState

    @PresentableStore
    var store: HomeStore

    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(state.claims, id: \.id) { claim in
                        ClaimStatus(claim: claim)
                            .frame(width: state.frameWidth * 0.9)
                            .padding(.top)
                            .padding(.bottom, 5)
                    }
                }
                .padding([.leading, .trailing], 14)
            }
            .padding([.leading, .trailing], -14)
            .background(
                GeometryReader { geo in
                    Color.clear.onReceive(Just(geo.size.width)) { width in
                        state.updateFrameWidth(width: width)
                    }
                }
            )
            .introspectScrollView { scrollView in
                state.scrollView = scrollView
            }
            hPagerDots(currentIndex: state.currentIndex, totalCount: state.claims.count)
                .padding(.bottom, 5)
        }
        //        .trackOnAppear(state.onAppearAnalyticsClosure)
    }
}
