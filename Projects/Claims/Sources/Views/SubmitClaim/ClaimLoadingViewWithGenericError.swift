import Foundation
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

private struct ClaimLoadingViewWithGenericError<StoreType: StoreLoading & Store>: ViewModifier {
    let loading: [StoreType.Loading]
    @PresentableStore var store: SubmitClaimStore
    func body(content: Content) -> some View {
        LoadingViewWithGenericError(
            StoreType.self,
            loading,
            showLoading: false,
            bottomAction: {
                store.send(.dismissNewClaimFlow)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    store.send(.submitClaimOpenFreeTextChat)
                }
            }
        ) {
            content
        }
    }
}

extension View {
    func claimErrorTrackerFor<StoreType: SubmitClaimStore>(_ loading: [StoreType.Loading]) -> some View {
        modifier(ClaimLoadingViewWithGenericError<StoreType>(loading: loading))
    }
}
