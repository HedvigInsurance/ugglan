import SwiftUI
import hCore

public enum ProcessingState: Equatable {
    case loading
    case success
    case error(errorMessage: String)
}

public struct ProcessingStateView: View {
    @StateObject var vm = ProcessingViewModel()
    @Binding var state: ProcessingState
    var showSuccessScreen: Bool

    var loadingViewText: String
    var successViewTitle: String?
    var successViewBody: String?
    var successViewButtonAction: (() -> Void)?

    var onAppearLoadingView: (() -> Void)?
    var onErrorCancelAction: (() -> Void)?
    var onLoadingDismiss: (() -> Void)?

    var errorViewButtons: ErrorViewButtonConfig?
    @Environment(\.hSuccessBottomAttachedView) var successBottomView

    public init(
        showSuccessScreen: Bool? = true,
        loadingViewText: String,
        successViewTitle: String? = nil,
        successViewBody: String? = nil,
        successViewButtonAction: (() -> Void)? = nil,
        onAppearLoadingView: (() -> Void)? = nil,
        onErrorCancelAction: (() -> Void)? = nil,
        onLoadingDismiss: (() -> Void)? = nil,
        errorViewButtons: ErrorViewButtonConfig? = nil,
        state: Binding<ProcessingState>
    ) {
        self.showSuccessScreen = showSuccessScreen ?? true
        self.loadingViewText = loadingViewText
        self.successViewTitle = successViewTitle
        self.successViewBody = successViewBody
        self.successViewButtonAction = successViewButtonAction
        self.onAppearLoadingView = onAppearLoadingView
        self.onErrorCancelAction = onErrorCancelAction
        self.onLoadingDismiss = onLoadingDismiss
        self.errorViewButtons = errorViewButtons
        self._state = state
    }

    public var body: some View {
        switch state {
        case .loading:
            loadingView
        case .success:
            successView
        case let .error(errorMessage):
            errorView(errorMessage: errorMessage)
        }
    }

    @ViewBuilder
    private var successView: some View {
        if showSuccessScreen {
            if successBottomView != nil {
                SuccessScreen(title: successViewTitle ?? "", subtitle: successViewBody ?? "")
            } else {
                SuccessScreen(
                    successViewTitle: successViewTitle ?? "",
                    successViewBody: successViewBody ?? "",
                    buttons: .init(
                        actionButton: nil,
                        primaryButton: nil,
                        ghostButton: .init(buttonAction: successViewButtonAction ?? {})
                    )
                )
            }
        } else {
            loadingView
                .onAppear {
                    onAppearLoadingView?()
                }
        }
    }

    @ViewBuilder
    private func errorView(errorMessage: String?) -> some View {
        GenericErrorView(
            title: L10n.somethingWentWrong,
            description: errorMessage,
            buttons: errorViewButtons
                ?? .init(
                    dismissButton: .init(
                        buttonTitle: L10n.generalCancelButton,
                        buttonAction: {
                            onErrorCancelAction?()
                        }
                    )
                )
        )
    }

    @ViewBuilder
    private var loadingView: some View {
        hSection {
            VStack(spacing: 20) {
                Spacer()
                hText(loadingViewText)
                ProgressView(value: vm.progress)
                    .frame(width: UIScreen.main.bounds.width * 0.53)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.easeInOut(duration: 1.5).delay(0.5)) {
                                vm.progress = 1
                            }
                        }
                    }
                    .progressViewStyle(hProgressViewStyle())
                Spacer()
                Spacer()
                if let onDismiss = onLoadingDismiss {
                    hSection {
                        hButton.LargeButton(type: .ghost) {
                            onDismiss()
                        } content: {
                            hText(L10n.generalCancelButton)
                        }
                    }
                    .sectionContainerStyle(.transparent)
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

#Preview(body: {
    ProcessingStateView(loadingViewText: "loading...", state: .constant(.error(errorMessage: "error message")))
})
