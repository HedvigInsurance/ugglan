import Presentation
import SwiftUI
import hCore

public struct LoadingViewWithState<Content: View, LoadingView: View, ErrorView: View>: View {
    var content: () -> Content
    var onLoading: () -> LoadingView
    var onError: (_ error: String) -> ErrorView

    @PresentableStore var store: ClaimsStore
    private let action: ClaimsAction
    public init(
        _ action: ClaimsAction,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder onLoading: @escaping () -> LoadingView,
        @ViewBuilder onError: @escaping (_ error: String) -> ErrorView
    ) {
        self.action = action
        self.content = content
        self.onLoading = onLoading
        self.onError = onError
    }
    public var body: some View {
        ZStack {
            PresentableStoreLens(
                ClaimsStore.self,
                getter: { state in
                    state.loadingStates
                }
            ) { loadingStates in
                if let state = loadingStates[action] {
                    switch state {
                    case .loading:
                        onLoading()
                    case let .error(error):
                        onError(error)
                    }
                } else {
                    content()
                }
            }
            .presentableStoreLensAnimation(.easeInOut)
        }

    }
}
