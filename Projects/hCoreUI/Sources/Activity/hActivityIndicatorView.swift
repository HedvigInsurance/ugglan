import Foundation
import StoreContainer
import SwiftUI

public struct hLoadingViewWithContent<Content: View, StoreType: StoreLoading & Store>: View {
    var content: () -> Content
    @hPresentableStore var store: StoreType
    private let actions: [StoreType.Loading]
    @Environment(\.presentableStoreLensAnimation) var animation
    @State var presentError = false
    @State var error = ""
    @State var isLoading = false
    let retryActions: [StoreType.Action]
    private let showLoading: Bool
    public init(
        _ type: StoreType.Type,
        _ actions: [StoreType.Loading],
        _ retryActions: [StoreType.Action],
        showLoading: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.actions = actions
        self.content = content
        self.showLoading = showLoading
        self.retryActions = retryActions
    }

    public var body: some View {
        ZStack {
            BackgroundView().edgesIgnoringSafeArea(.all)
            if isLoading && showLoading {
                loadingIndicatorView.transition(.opacity.animation(animation ?? .easeInOut(duration: 0.2)))
            } else if presentError {
                GenericErrorView(
                    description: error,
                    buttons: .init(
                        actionButton: .init(buttonAction: {
                            for action in retryActions {
                                store.send(action)
                            }
                        }),
                        dismissButton: nil
                    )
                )
            } else {
                content().transition(.opacity.animation(animation ?? .easeInOut(duration: 0.2)))
            }
        }
        .onReceive(
            store.loadingSignal
        ) { value in
            handle(allActions: value)
        }
        .onAppear {
            let store: StoreType = hGlobalPresentableStoreContainer.get()
            if let state = handle(allActions: store.loadingState) {
                isLoading = state.isLoading
                error = state.error ?? ""
                presentError = state.presentError
            }
        }
    }

    @discardableResult
    private func handle(
        allActions: [StoreType.Loading: LoadingState<String>]
    ) -> hLoadingViewWithContent.ChangeStateValue? {
        let actions = allActions.filter({ self.actions.contains($0.key) })
        var state: hLoadingViewWithContent.ChangeStateValue?
        if actions.count > 0 {
            if actions.filter({ $0.value == .loading }).count > 0 {
                state = .init(isLoading: true, presentError: false, error: nil)
            } else {
                var tempError = ""
                for action in actions {
                    switch action.value {
                    case .error(let error):
                        tempError = error
                    default:
                        break
                    }
                }
                state = .init(isLoading: false, presentError: true, error: tempError)
            }
        } else {
            state = .init(isLoading: false, presentError: false, error: nil)
        }
        if let state {
            print("STATE IS \(state)")
            changeState(to: state)
        }
        return state
    }
    private func changeState(to state: hLoadingViewWithContent.ChangeStateValue) {
        DispatchQueue.main.async {
            if let animation {
                withAnimation(animation) {
                    self.error = state.error ?? ""
                    self.isLoading = state.isLoading
                    self.presentError = state.presentError
                }
            } else {
                self.error = state.error ?? ""
                self.isLoading = state.isLoading
                self.presentError = state.presentError
            }
        }
    }

    @ViewBuilder
    private var loadingIndicatorView: some View {
        HStack {
            DotsActivityIndicator(.standard)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(hBackgroundColor.primary.opacity(0.01))
        .edgesIgnoringSafeArea(.top)
        .useDarkColor
    }

    private struct ChangeStateValue {
        let isLoading: Bool
        let presentError: Bool
        let error: String?
    }
}

extension View {
    public func hTrackLoading<StoreType: StoreLoading & Store>(
        _ type: StoreType.Type,
        action: StoreType.Loading
    ) -> some View {
        modifier(hTrackLoadingButtonModifier(type, action))
    }
}

struct hTrackLoadingButtonModifier<StoreType: StoreLoading & Store>: ViewModifier {
    @hPresentableStore var store: StoreType
    let actions: [StoreType.Loading]
    @State private var isLoading = false
    @Environment(\.presentableStoreLensAnimation) var animation

    public init(
        _ type: StoreType.Type,
        _ action: StoreType.Loading
    ) {
        self.actions = [action]
    }
    func body(content: Content) -> some View {
        content
            .onReceive(
                store.loadingSignal
            ) { value in
                handle(allActions: value)
            }
            .onAppear {
                handle(allActions: store.loadingState)
            }
            .hButtonIsLoading(isLoading)
    }

    func handle(allActions: [StoreType.Loading: LoadingState<String>]) {
        let actions = allActions.filter({ self.actions.contains($0.key) })
        if actions.count > 0 {
            if actions.filter({ $0.value == .loading }).count > 0 {
                changeState(to: true, presentError: false)
            } else {
                var tempError = ""
                for action in actions {
                    switch action.value {
                    case .error(let error):
                        tempError = error
                    default:
                        break
                    }
                }
                changeState(to: false, presentError: true, error: tempError)
            }
        } else {
            changeState(to: false, presentError: false, error: nil)
        }
    }
    private func changeState(to isLoading: Bool, presentError: Bool, error: String? = nil) {
        if let animation {
            withAnimation(animation) {
                self.isLoading = isLoading
            }
        } else {
            self.isLoading = isLoading
        }
    }
}
