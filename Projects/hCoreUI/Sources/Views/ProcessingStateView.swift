import SwiftUI
import hCore

public enum ProcessingState: Equatable {
    case loading
    case success
    case error(errorMessage: String)
}

private struct AnimationTiming {
    let delay: Float
    let duration: Float
    let progress: Float
}

public struct ProcessingStateView: View {
    @StateObject var vm = ProcessingViewModel()
    @Binding var state: ProcessingState
    fileprivate let animationTimings: [AnimationTiming]
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
        state: Binding<ProcessingState>,
        duration: Float = 1.5
    ) {
        self.loadingViewText = loadingViewText
        self.successViewTitle = successViewTitle
        self.successViewBody = successViewBody
        self.successViewButtonAction = successViewButtonAction
        self.errorViewButtons = errorViewButtons
        self._state = state

        let baseDurationFactor: Float = duration * (Float(1) / Float(24))
        animationTimings = [
            .init(delay: 0.5, duration: baseDurationFactor * 8, progress: 0.3),
            .init(
                delay: 0.5 + baseDurationFactor * 8,
                duration: baseDurationFactor * 4,
                progress: Float.random(in: 0.3...0.5)
            ),
            .init(delay: 0.5 + baseDurationFactor * 12, duration: baseDurationFactor * 3, progress: 0.6),
            .init(delay: 0.5 + baseDurationFactor * 15, duration: baseDurationFactor, progress: 0.7),
            .init(
                delay: 0.5 + baseDurationFactor * 16,
                duration: baseDurationFactor * 6,
                progress: Float.random(in: 0.7...0.95)
            ),
            .init(delay: 0.5 + baseDurationFactor * 22, duration: baseDurationFactor * 2, progress: 1),
        ]
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
                            animationTimings.forEach { item in
                                withAnimation(
                                    .easeInOut(duration: TimeInterval(item.duration)).delay(TimeInterval(item.delay))
                                ) {
                                    vm.progress = item.progress
                                }
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
