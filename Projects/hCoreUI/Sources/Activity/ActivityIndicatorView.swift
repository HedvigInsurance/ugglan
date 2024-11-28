import Foundation
import PresentableStore
import SwiftUI
import hCore

public struct LoadingStoreViewWithContent<Content: View, StoreType: StoreLoading & Store>: View {
    var content: () -> Content
    @PresentableStore var store: StoreType
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
                    description: error
                )
                .hErrorViewButtonConfig(
                    .init(
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
            let store: StoreType = globalPresentableStoreContainer.get()
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
    ) -> LoadingStoreViewWithContent.ChangeStateValue? {
        let actions = allActions.filter({ self.actions.contains($0.key) })
        var state: LoadingStoreViewWithContent.ChangeStateValue?
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
    private func changeState(to state: LoadingStoreViewWithContent.ChangeStateValue) {
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

struct LoadingViewWithContent: ViewModifier {
    @Binding var isLoading: Bool
    @Binding var error: String?
    func body(content: Content) -> some View {
        ZStack {
            BackgroundView().edgesIgnoringSafeArea(.all)
            if isLoading {
                loadingIndicatorView.transition(.opacity.animation(.easeInOut(duration: 0.2)))
            } else if let error = error {
                GenericErrorView(
                    description: error
                )
                .hErrorViewButtonConfig(.init())
                .transition(.opacity.animation(.easeInOut(duration: 0.2)))
            } else {
                content.transition(.opacity.animation(.easeInOut(duration: 0.2)))
            }
        }
    }

    private var loadingIndicatorView: some View {
        HStack {
            DotsActivityIndicator(.standard)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(hBackgroundColor.primary.opacity(0.01))
        .edgesIgnoringSafeArea(.top)
        .useDarkColor
    }
}

struct LoadingViewWithContentForProcessingState: ViewModifier {
    @Binding var state: ProcessingState
    public func body(content: Content) -> some View {
        ZStack {
            BackgroundView().edgesIgnoringSafeArea(.all)
            switch state {
            case .loading:
                loadingIndicatorView.transition(.opacity.animation(.easeInOut(duration: 0.2)))
            case .success:
                content.transition(.opacity.animation(.easeInOut(duration: 0.2)))
            case .error(let errorMessage):
                GenericErrorView(
                    description: errorMessage,
                    useForm: false
                )
                .transition(.opacity.animation(.easeInOut(duration: 0.2)))
            }
        }
    }

    private var loadingIndicatorView: some View {
        HStack {
            DotsActivityIndicator(.standard)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(hBackgroundColor.primary.opacity(0.01))
        .edgesIgnoringSafeArea(.top)
        .useDarkColor
    }
}

struct LoadingViewForButtonForProcessingState: ViewModifier {
    @Binding var state: ProcessingState
    public func body(content: Content) -> some View {
        ZStack {
            BackgroundView().edgesIgnoringSafeArea(.all)
            switch state {
            case .success, .loading:
                content.transition(.opacity.animation(.easeInOut(duration: 0.2))).hButtonIsLoading(state == .loading)
            case .error(let errorMessage):
                GenericErrorView(
                    description: errorMessage
                )
                .transition(.opacity.animation(.easeInOut(duration: 0.2)))
            }
        }
    }

    private var loadingIndicatorView: some View {
        HStack {
            DotsActivityIndicator(.standard)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(hBackgroundColor.primary.opacity(0.01))
        .edgesIgnoringSafeArea(.top)
        .useDarkColor
    }
}

extension View {
    public func loading(_ isLoading: Binding<Bool>, _ error: Binding<String?>) -> some View {
        modifier(LoadingViewWithContent(isLoading: isLoading, error: error))
    }

    public func loading(_ state: Binding<ProcessingState>) -> some View {
        modifier(LoadingViewWithContentForProcessingState(state: state))
    }

    public func loadingButtonWithErrorHandling(_ state: Binding<ProcessingState>) -> some View {
        modifier(LoadingViewForButtonForProcessingState(state: state))
    }
}
