import Flow
import Presentation
import SwiftUI
import hAnalytics
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
    private let actions: [ClaimsLoadingType]
    private let hUseNewStyle: Bool

    @State var presentError = false
    @State var error = ""
    @State var isLoading = false
    var disposeBag = DisposeBag()

    public init(
        hUseNewStyle: Bool = true,
        _ action: ClaimsLoadingType,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.hUseNewStyle = hUseNewStyle
        self.actions = [action]
        self.content = content
    }

    public init(
        hUseNewStyle: Bool = true,
        _ actions: [ClaimsLoadingType],
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.hUseNewStyle = hUseNewStyle
        self.actions = actions
        self.content = content
    }

    public var body: some View {
        ZStack {
            contentView
            if isLoading {
                loadingIndicatorView.transition(.opacity.animation(.easeInOut(duration: 0.1)))
            }
        }
        .onAppear {
            func handle(state: SubmitClaimsState) {
                let actions = state.loadingStates.filter({ self.actions.contains($0.key) })
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

    @ViewBuilder
    private var contentView: some View {
        if hUseNewStyle {
            content()
                .blur(radius: isLoading ? 10 : 0)
                .alert(isPresented: $presentError) {
                    Alert(
                        title: Text(L10n.somethingWentWrong),
                        message: Text(error),
                        dismissButton: .default(Text(L10n.alertOk)) {
                            for action in actions {
                                store.send(.setLoadingState(action: action, state: nil))
                            }
                        }
                    )
                }
        } else {
            content()
                .alert(isPresented: $presentError) {
                    Alert(
                        title: Text(L10n.somethingWentWrong),
                        message: Text(error),
                        dismissButton: .default(Text(L10n.alertOk)) {
                            for action in actions {
                                store.send(.setLoadingState(action: action, state: nil))
                            }
                        }
                    )
                }
        }
    }
    @ViewBuilder
    private var loadingIndicatorView: some View {
        if hUseNewStyle {
            HStack {
                DotsActivityIndicator(.standard)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(hBackgroundColorNew.primary.opacity(0.01))
            .edgesIgnoringSafeArea(.top)
        } else {
            HStack {
                WordmarkActivityIndicator(.standard)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(hBackgroundColor.primary.opacity(0.7))
            .cornerRadius(.defaultCornerRadius)
            .edgesIgnoringSafeArea(.top)
        }
    }
}

public enum ButtonStyleForLoading {
    case filledButton
    case textButton
}

public struct LoadingButtonWithContent<Content: View>: View {
    var content: () -> Content
    let buttonAction: () -> Void
    @PresentableStore var store: SubmitClaimStore
    private let actions: [ClaimsLoadingType]
    private let hUseNewStyle: Bool
    let buttonStyleSelect: ButtonStyleForLoading?

    @State var presentError = false
    @State var error = ""
    @State var isLoading = false
    var disposeBag = DisposeBag()

    public init(
        hUseNewStyle: Bool = true,
        _ action: ClaimsLoadingType,
        buttonAction: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content,
        buttonStyleSelect: ButtonStyleForLoading? = .filledButton
    ) {
        self.hUseNewStyle = hUseNewStyle
        self.actions = [action]
        self.buttonAction = buttonAction
        self.content = content
        self.buttonStyleSelect = buttonStyleSelect
    }

    public init(
        hUseNewStyle: Bool = true,
        _ actions: [ClaimsLoadingType],
        buttonAction: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content,
        buttonStyleSelect: ButtonStyleForLoading? = .filledButton
    ) {
        self.hUseNewStyle = hUseNewStyle
        self.actions = actions
        self.buttonAction = buttonAction
        self.content = content
        self.buttonStyleSelect = buttonStyleSelect
    }

    public var body: some View {

        switch buttonStyleSelect {
        case .filledButton:
            hButton.LargeButtonFilled {
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
            .onAppear {
                getOnAppear
            }
        case .textButton:
            hButton.LargeButtonText {
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
            .onAppear {
                getOnAppear
            }
        case .none:
            EmptyView()
        }
    }

    private var getOnAppear: Void {
        func handle(state: SubmitClaimsState) {
            let actions = state.loadingStates.filter({ self.actions.contains($0.key) })
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
        let store: SubmitClaimStore = globalPresentableStoreContainer.get()
        disposeBag += store.stateSignal.onValue { state in
            handle(state: state)
        }
        handle(state: store.state)
    }

    @ViewBuilder
    private var contentView: some View {
        if hUseNewStyle {
            content()
                .blur(radius: isLoading ? 10 : 0)
                .alert(isPresented: $presentError) {
                    Alert(
                        title: Text(L10n.somethingWentWrong),
                        message: Text(error),
                        dismissButton: .default(Text(L10n.alertOk)) {
                            for action in actions {
                                store.send(.setLoadingState(action: action, state: nil))
                            }
                        }
                    )
                }
        } else {
            content()
                .alert(isPresented: $presentError) {
                    Alert(
                        title: Text(L10n.somethingWentWrong),
                        message: Text(error),
                        dismissButton: .default(Text(L10n.alertOk)) {
                            for action in actions {
                                store.send(.setLoadingState(action: action, state: nil))
                            }
                        }
                    )
                }
        }
    }
    @ViewBuilder
    private var loadingIndicatorView: some View {
        if hUseNewStyle {
            HStack {
                DotsActivityIndicator(.standard)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(hBackgroundColorNew.primary.opacity(0.01))
            .edgesIgnoringSafeArea(.top)
        } else {
            HStack {
                WordmarkActivityIndicator(.standard)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(hBackgroundColor.primary.opacity(0.7))
            .cornerRadius(.defaultCornerRadius)
            .edgesIgnoringSafeArea(.top)
        }
    }
}

struct LoadingButtonWithContent_Previews: PreviewProvider {
    static var previews: some View {
        LoadingButtonWithContent(
            .startClaim,
            buttonAction: {
            },
            content: {
                Text("TEXT")
            },
            buttonStyleSelect: .filledButton
        )
    }
}
