import Flow
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct LoadingViewWithState<Content: View, LoadingView: View, ErrorView: View>: View {
    var content: () -> Content
    var onLoading: () -> LoadingView
    var onError: (_ error: String) -> ErrorView

    @PresentableStore var store: SubmitClaimStore
    private let action: ClaimsLoadingType
    public init(
        _ action: ClaimsLoadingType,
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
        PresentableStoreLens(
            SubmitClaimStore.self,
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

public struct LoadingViewWithContent<Content: View>: View {
    var content: () -> Content
    @PresentableStore var store: SubmitClaimStore
    private let action: ClaimsLoadingType

    @State var presentError = false
    @State var error = ""
    @State var isLoading = false
    var disposeBag = DisposeBag()

    public init(
        _ action: ClaimsLoadingType,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.action = action
        self.content = content
    }
    public var body: some View {
        ZStack {
            content()
                .alert(isPresented: $presentError) {
                    Alert(
                        title: Text(L10n.somethingWentWrong),
                        message: Text(error),
                        dismissButton: .default(Text(L10n.alertOk))
                    )
                }
            if isLoading {
                HStack {
                    WordmarkActivityIndicator(.standard)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(hBackgroundColor.primary.opacity(0.7))
                .cornerRadius(.defaultCornerRadius)
                .edgesIgnoringSafeArea(.top)
            }
        }
        .onAppear {
            func handle(state: SubmitClaimsState) {
                if let actionState = state.loadingStates[action] {
                    switch actionState {
                    case .loading:
                        withAnimation {
                            self.isLoading = true
                            self.presentError = false
                        }
                    case let .error(error):
                        withAnimation {
                            self.isLoading = false
                            self.error = error
                            self.presentError = true
                        }
                    }
                } else {
                    withAnimation {
                        self.isLoading = false
                        self.presentError = false
                    }
                }
            }
            let store: SubmitClaimStore = globalPresentableStoreContainer.get()
            disposeBag += store.stateSignal.onValue { state in
                handle(state: state)
            }
            handle(state: store.state)

        }
    }
}
