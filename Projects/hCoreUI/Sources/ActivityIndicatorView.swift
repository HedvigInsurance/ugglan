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
    var disposeBag = DisposeBag()

    public init(
        _ type: StoreType.Type,
        _ actions: [StoreType.Loading],
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.actions = actions
        self.content = content
    }

    public var body: some View {
        ZStack {
            contentView
            if isLoading {
                loadingIndicatorView.transition(.opacity.animation(animation ?? .easeInOut(duration: 0.2)))
            }
        }
        .onReceive(
            store.loadingSignal
                .plain()
                .publisher
        ) { value in
            let actions = value.filter({ self.actions.contains($0.key) })
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
    private var contentView: some View {
        content()
            .blur(radius: isLoading ? 10 : 0)
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
    }
    @ViewBuilder
    private var loadingIndicatorView: some View {
        HStack {
            DotsActivityIndicator(.standard)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(hBackgroundColorNew.primary.opacity(0.01))
        .edgesIgnoringSafeArea(.top)
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
            hButton.LargeButtonPrimary {
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
        case .none:
            EmptyView()
        }
    }
}
