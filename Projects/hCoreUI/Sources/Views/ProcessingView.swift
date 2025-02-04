import SwiftUI
import hCore

class ProcessingViewModel: ObservableObject {
    @Published var progress: Float = 0
}

public struct ProcesssingView: View {
    @StateObject var vm = ProcessingViewModel()
    var showSuccessScreen: Bool
    @Binding var isLoading: Bool
    @Binding var error: String?

    var loadingViewText: String
    var successViewTitle: String?
    var successViewBody: String?
    var successViewButtonAction: (() -> Void)?

    var onAppearLoadingView: (() -> Void)?
    var onErrorCancelAction: (() -> Void)?
    var onLoadingDismiss: (() -> Void)?

    var errorViewButtons: ErrorViewButtonConfig?

    public init(
        showSuccessScreen: Bool? = true,
        isLoading: Binding<Bool>,
        error: Binding<String?>,
        loadingViewText: String,
        successViewTitle: String? = nil,
        successViewBody: String? = nil,
        successViewButtonAction: (() -> Void)? = nil,
        onAppearLoadingView: (() -> Void)? = nil,
        onErrorCancelAction: (() -> Void)? = nil,
        onLoadingDismiss: (() -> Void)? = nil,
        errorViewButtons: ErrorViewButtonConfig? = nil
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
        self._isLoading = isLoading
        self._error = error
    }

    public var body: some View {
        BlurredProgressOverlay {
            if isLoading {
                loadingView
            } else if error != nil {
                errorView
            } else {
                if showSuccessScreen {
                    SuccessScreen(
                        title: successViewTitle,
                        subtitle: successViewBody
                    )
                } else {
                    loadingView
                        .onAppear {
                            onAppearLoadingView?()
                        }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.easeInOut(duration: 1.25)) {
                    vm.progress = 1
                }
            }
        }
    }

    private var errorView: some View {
        ZStack(alignment: .bottom) {
            BackgroundView().ignoresSafeArea()
            GenericErrorView(
                formPosition: .center
            )
            .hErrorViewButtonConfig(
                errorViewButtons
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
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            Spacer()
            hText(loadingViewText)
            ProgressView(value: vm.progress)
                .frame(width: UIScreen.main.bounds.width * 0.53)
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
