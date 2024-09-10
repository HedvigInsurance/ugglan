import Foundation
import PresentableStore
import SwiftUI
import hCore

public struct LoadingViewWithState<Content: View, LoadingView: View, ErrorView: View, StoreType: StoreLoading & Store>:
    View
{
    var content: () -> Content
    var onLoading: () -> LoadingView
    var onError: (_ error: String) -> ErrorView

    var action: StoreType.Loading
    @State var showOnLoading: Bool = false
    @State var error: String?

    @PresentableStore var store: StoreType

    public init(
        _ type: StoreType.Type,
        _ action: StoreType.Loading,
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
        getView
            .onReceive(
                store.loadingSignal
            ) { value in
                withAnimation {
                    if let state = value[action] {
                        switch state {
                        case .loading:
                            showOnLoading = true
                            self.error = nil
                        case let .error(error):
                            showOnLoading = false
                            self.error = error
                        }
                    } else {
                        showOnLoading = false
                        self.error = nil
                    }
                }
            }
            .onAppear {
                withAnimation {
                    if let state = store.loadingState[action] {
                        switch state {
                        case .loading:
                            showOnLoading = true
                            self.error = nil
                        case let .error(error):
                            showOnLoading = false
                            self.error = error
                        }
                    } else {
                        showOnLoading = false
                        self.error = nil
                    }
                }
            }
    }

    @ViewBuilder
    private var getView: some View {
        if let error {
            onError(error)
        } else if showOnLoading {
            onLoading()
        } else {
            content()
        }
    }
}

public struct LoadingViewWithContent<Content: View, StoreType: StoreLoading & Store>: View {
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
    ) -> LoadingViewWithContent.ChangeStateValue? {
        let actions = allActions.filter({ self.actions.contains($0.key) })
        var state: LoadingViewWithContent.ChangeStateValue?
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
    private func changeState(to state: LoadingViewWithContent.ChangeStateValue) {
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
    public func trackLoading<StoreType: StoreLoading & Store>(
        _ type: StoreType.Type,
        action: StoreType.Loading
    ) -> some View {
        modifier(trackLoadingButtonModifier(type, action))
    }
}

struct trackLoadingButtonModifier<StoreType: StoreLoading & Store>: ViewModifier {
    @PresentableStore var store: StoreType
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

extension View {
    public func hRetryView<StoreType: StoreLoading & Store>(
        _ type: StoreType.Type,
        forAction action: StoreType.Loading,
        binding: Binding<String?>
    ) -> some View {
        modifier(RetryViewWithError(type, action, binding))
    }
}

private struct RetryViewWithError<StoreType: StoreLoading & Store>: ViewModifier {
    @PresentableStore var store: StoreType
    let action: StoreType.Loading
    @Binding private var error: String?
    @Environment(\.presentableStoreLensAnimation) var animation

    public init(
        _ type: StoreType.Type,
        _ action: StoreType.Loading,
        _ binding: Binding<String?>
    ) {
        self.action = action
        _error = binding
    }
    func body(content: Content) -> some View {
        ZStack {
            if let error {
                GenericErrorView(
                    description: error,
                    buttons: .init(
                        actionButton: .init(buttonAction: {
                            self.error = nil
                        }),
                        dismissButton: nil
                    )
                )
            } else {
                content
            }
        }
        .onReceive(
            store.loadingSignal
        ) { value in
            handle(allActions: value)
        }
        .onAppear {
            handle(allActions: store.loadingState)
        }
    }

    func handle(allActions: [StoreType.Loading: LoadingState<String>]) {
        if let state = allActions[action] {
            switch state {
            case .loading:
                withAnimation {
                    self.error = nil
                }
            case let .error(error):
                withAnimation {
                    self.error = error
                }
            }
        } else {
            withAnimation {
                self.error = nil
            }
        }
    }
}

public struct LoadingViewWithGenericError<Content: View, StoreType: StoreLoading & Store>: View {
    var content: () -> Content
    @PresentableStore var store: StoreType
    private let actions: [StoreType.Loading]
    @Environment(\.presentableStoreLensAnimation) var animation
    @State var presentError = false
    @State var error = ""
    @State var isLoading = false
    let bottomAction: () -> Void
    private let showLoading: Bool
    public init(
        _ type: StoreType.Type,
        _ actions: [StoreType.Loading],
        showLoading: Bool = true,
        bottomAction: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.actions = actions
        self.content = content
        self.showLoading = showLoading
        self.bottomAction = bottomAction

    }

    public var body: some View {
        ZStack {
            BackgroundView().edgesIgnoringSafeArea(.all)
            if isLoading && showLoading {
                loadingIndicatorView.transition(.opacity.animation(animation ?? .easeInOut(duration: 0.2)))
            } else if presentError {
                GenericErrorView(
                    title: L10n.somethingWentWrong,
                    description: error,
                    buttons: .init(
                        actionButton: .init(buttonAction: {
                            for action in actions {
                                store.removeLoading(for: action)
                            }
                        }),
                        dismissButton: .init(
                            buttonTitle: L10n.openChat,
                            buttonAction: {
                                bottomAction()
                            }
                        )
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
    ) -> LoadingViewWithGenericError.ChangeStateValue? {
        let actions = allActions.filter({ self.actions.contains($0.key) })
        var state: LoadingViewWithGenericError.ChangeStateValue?
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
            changeState(to: state)
        }
        return state
    }
    private func changeState(to state: LoadingViewWithGenericError.ChangeStateValue) {
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

public struct LoadingViewWithContentt: ViewModifier {
    @Binding var isLoading: Bool
    @Binding var error: String?
    public func body(content: Content) -> some View {
        ZStack {
            BackgroundView().edgesIgnoringSafeArea(.all)
            if isLoading {
                loadingIndicatorView.transition(.opacity.animation(.easeInOut(duration: 0.2)))
            } else if let error = error {
                GenericErrorView(
                    description: error,
                    buttons: .init()
                )
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

extension View {
    public func hLoading(_ isLoading: Binding<Bool>, _ error: Binding<String?>) -> some View {
        modifier(LoadingViewWithContentt(isLoading: isLoading, error: error))
    }
}
