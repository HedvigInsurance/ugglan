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

class ProcessingViewModel: ObservableObject {
    @Published var progress: Float = 0
}

public struct hProgressViewStyle: ProgressViewStyle {
    public init() {}
    public func makeBody(configuration: LinearProgressViewStyle.Configuration) -> some View {
        return RoundedRectangle(cornerRadius: 2).fill(hSurfaceColor.Translucent.secondary)
            .overlay {
                GeometryReader(content: { geometry in
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(hFillColor.Opaque.primary)
                        .frame(width: geometry.size.width * (configuration.fractionCompleted ?? 0))
                })
            }
            .frame(height: 4)
    }
}

public struct ProcessingStateView: View {
    @StateObject var vm = ProcessingViewModel()
    @Binding var state: ProcessingState
    fileprivate let animationTimings: [AnimationTiming]
    var loadingViewText: String
    var successViewTitle: String?
    var successViewBody: String?
    var successViewButtonAction: (() -> Void)?
    var onAppearLoadingView: (() -> Void)?
    var showSuccessScreen: Bool

    @Environment(\.hCustomSuccessView) var customSuccessView
    @Environment(\.hSuccessBottomAttachedView) var successBottomView

    public init(
        showSuccessScreen: Bool? = true,
        loadingViewText: String,
        successViewTitle: String? = nil,
        successViewBody: String? = nil,
        successViewButtonAction: (() -> Void)? = nil,
        onAppearLoadingView: (() -> Void)? = nil,
        state: Binding<ProcessingState>,
        duration: Float = 1.5
    ) {
        self.showSuccessScreen = showSuccessScreen ?? true
        self.loadingViewText = loadingViewText
        self.successViewTitle = successViewTitle
        self.successViewBody = successViewBody
        self.successViewButtonAction = successViewButtonAction
        self.onAppearLoadingView = onAppearLoadingView
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
            if showSuccessScreen {
                if successBottomView != nil {
                    bottomSuccessView
                } else {
                    successView
                }
            } else {
                loadingView
                    .onAppear {
                        onAppearLoadingView?()
                    }
            }
        case let .error(errorMessage):
            errorView(errorMessage: errorMessage)
                .onAppear {
                    vm.progress = 0
                }
        }
    }

    @ViewBuilder
    private var bottomSuccessView: some View {
        SuccessScreen(title: successViewTitle ?? "", subtitle: successViewBody ?? "")
    }

    @ViewBuilder
    private var successView: some View {
        if customSuccessView != nil {
            customSuccessView
        } else {
            SuccessScreen(
                successViewTitle: successViewTitle ?? "",
                successViewBody: successViewBody ?? ""
            )
            .hStateViewButtonConfig(successButtonsView)
        }
    }

    private var successButtonsView: StateViewButtonConfig? {
        if successBottomView == nil {
            return .init(
                actionButton: nil,
                actionButtonAttachedToBottom: nil,
                dismissButton: .init(buttonTitle: L10n.generalCloseButton, buttonAction: successViewButtonAction ?? {})
            )
        }
        return nil
    }

    @ViewBuilder
    private func errorView(errorMessage: String?) -> some View {
        GenericErrorView(
            title: L10n.somethingWentWrong,
            description: errorMessage,
            formPosition: .center
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
        state: .constant(.error(errorMessage: "error message"))
    )
})

extension View {
    public func trackErrorState(for state: Binding<ProcessingState>) -> some View {
        self.modifier(TrackErrorState(processingState: state))
    }
}
private struct TrackErrorState: ViewModifier {
    @State private var error: String?
    @Binding var processingState: ProcessingState
    func body(content: Content) -> some View {
        Group {
            if let error {
                GenericErrorView(
                    description: error,
                    formPosition: .center
                )
            } else {
                content
            }
        }
        .onAppear {
            checkForError()
        }
        .onChange(of: processingState) { value in
            checkForError()
        }
    }

    private func checkForError() {
        withAnimation {
            switch processingState {
            case let .error(errorMessage):
                self.error = errorMessage
            default:
                self.error = nil
            }
        }
    }
}
