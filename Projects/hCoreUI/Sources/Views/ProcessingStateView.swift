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

    var loadingViewText: String

    var successViewTitle: String?
    var successViewBody: String?
    var successViewButtonAction: (() -> Void)?

    var errorViewButtons: ErrorViewButtonConfig

    @Environment(\.hCustomSuccessView) var customSuccessView

    public init(
        loadingViewText: String,
        successViewTitle: String? = nil,
        successViewBody: String? = nil,
        successViewButtonAction: (() -> Void)? = nil,
        errorViewButtons: ErrorViewButtonConfig,
        state: Binding<ProcessingState>
    ) {
        self.loadingViewText = loadingViewText
        self.successViewTitle = successViewTitle
        self.successViewBody = successViewBody
        self.successViewButtonAction = successViewButtonAction
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
        if customSuccessView != nil {
            customSuccessView
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
    }

    @ViewBuilder
    private func errorView(errorMessage: String?) -> some View {
        GenericErrorView(
            title: L10n.somethingWentWrong,
            description: errorMessage,
            buttons: errorViewButtons
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
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

#Preview(body: {
    ProcessingStateView(
        loadingViewText: "loading...",
        errorViewButtons: .init(),
        state: .constant(.error(errorMessage: "error message"))
    )
})
