import Flow
import Foundation
import Presentation
import SwiftUI
import hAnalytics
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
                    .plain()
                    .publisher
            ) { value in
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
    var disposeBag = DisposeBag()
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
        let store: StoreType = globalPresentableStoreContainer.get()
        handle(allActions: store.loadingSignal.value)
    }

    public var body: some View {
        ZStack {
            BackgroundView().edgesIgnoringSafeArea(.all)
            if isLoading && showLoading {
                loadingIndicatorView.transition(.opacity.animation(animation ?? .easeInOut(duration: 0.2)))
            } else if presentError {
                RetryView(subtitle: error) {
                    for action in retryActions {
                        store.send(action)
                    }
                }
            } else {
                content().transition(.opacity.animation(animation ?? .easeInOut(duration: 0.2)))
            }
        }
        .onReceive(
            store.loadingSignal
                .plain()
                .publisher
        ) { value in
            handle(allActions: value)
        }
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
                self.error = error ?? ""
                self.isLoading = isLoading
                self.presentError = presentError
            }
        } else {
            self.error = error ?? ""
            self.isLoading = isLoading
            self.presentError = presentError
        }
    }

    @ViewBuilder
    private var loadingIndicatorView: some View {
        HStack {
            DotsActivityIndicator(.standard)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(hBackgroundColorNew.primary.opacity(0.01))
        .edgesIgnoringSafeArea(.top)
        .useDarkColor
    }
}

public enum ButtonStyleForLoading {
    case filledButton
    case textButton
}

public struct LoadingButtonWithContent<Content: View, StoreType: StoreLoading & Store>: View {
    var content: () -> Content
    let buttonAction: () -> Void
    @PresentableStore var store: StoreType
    private let actions: [StoreType.Loading]
    let buttonStyleSelect: ButtonStyleForLoading?

    @State var presentError = false
    @State var error = ""
    @State var isLoading = false
    var disposeBag = DisposeBag()

    public init(
        _ type: StoreType.Type,
        _ action: StoreType.Loading,
        buttonAction: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content,
        buttonStyleSelect: ButtonStyleForLoading? = .filledButton
    ) {
        self.actions = [action]
        self.buttonAction = buttonAction
        self.content = content
        self.buttonStyleSelect = buttonStyleSelect
    }

    public init(
        _ type: StoreType.Type,
        _ actions: [StoreType.Loading],
        buttonAction: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content,
        buttonStyleSelect: ButtonStyleForLoading? = .filledButton
    ) {
        self.actions = actions
        self.buttonAction = buttonAction
        self.content = content
        self.buttonStyleSelect = buttonStyleSelect
    }

    public var body: some View {
        loadingButton
            .alert(isPresented: $presentError) {
                Alert(
                    title: Text(L10n.somethingWentWrong),
                    message: Text(error),
                    dismissButton: .default(Text(L10n.alertOk)) {
                        for action in actions {
                            store.removeLoading(for: action)
                        }
                    }
                )
            }
            .onReceive(
                store.loadingSignal
                    .plain()
                    .publisher
            ) { value in
                let actions = value.filter({ self.actions.contains($0.key) })
                if actions.count > 0 {
                    if actions.filter({ $0.value == .loading }).count > 0 {
                        withAnimation {
                            self.isLoading = true
                            self.presentError = false
                        }
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
                        self.error = tempError
                        self.isLoading = false
                        self.presentError = true
                    }
                } else {
                    if isLoading == true {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.isLoading = false
                            self.presentError = false
                        }
                    } else {
                        withAnimation {
                            self.isLoading = false
                            self.presentError = false
                        }
                    }
                }
            }
    }

    @ViewBuilder
    var loadingButton: some View {
        switch buttonStyleSelect {
        case .filledButton:
            hButton.LargeButton(type: .primary) {
                if !isLoading {
                    buttonAction()
                }
            } content: {
                if !isLoading {
                    content()
                } else {
                    DotsActivityIndicator(.standard)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        case .textButton:
            hButton.LargeButton(type: .ghost) {
                if !isLoading {
                    buttonAction()
                }
            } content: {
                if !isLoading {
                    content()
                } else {
                    DotsActivityIndicator(.standard)
                        .useDarkColor
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        case .none:
            EmptyView()
        }
    }
}

struct TrackLoadingButtonModifier<StoreType: StoreLoading & Store>: ViewModifier {
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
                    .plain()
                    .publisher
            ) { value in
                handle(allActions: value)
            }
            .onAppear {
                handle(allActions: store.loadingSignal.value)
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
    public func trackLoading<StoreType: StoreLoading & Store>(
        _ type: StoreType.Type,
        action: StoreType.Loading
    ) -> some View {
        modifier(TrackLoadingButtonModifier(type, action))
    }
}
