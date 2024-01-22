import Presentation
import SwiftUI
import hCore

public struct ProcessingView<S: Store & StoreLoading, T>: View where T: View {
    @StateObject var vm = ProcessingViewModel()
    var showSuccessScreen: Bool
    var store: S.Type
    var loading: S.Loading
    var successView: T
    var loadingViewText: String
    var onAppearLoadingView: (() -> Void)?
    var onErrorCancelAction: (() -> Void)?

    public init(
        showSuccessScreen: Bool,
        _ storeType: S.Type,
        loading: S.Loading,
        successView: T,
        loadingViewText: String,
        onAppearLoadingView: (() -> Void)? = nil,
        onErrorCancelAction: (() -> Void)? = nil
    ) {
        self.showSuccessScreen = showSuccessScreen
        self.store = storeType
        self.loading = loading
        self.loadingViewText = loadingViewText
        self.successView = successView
        self.onAppearLoadingView = onAppearLoadingView
    }

    public var body: some View {
        BlurredProgressOverlay {
            PresentableLoadingStoreLens(
                store,
                loadingState: loading
            ) {
                loadingView
            } error: { error in
                errorView
            } success: {
                if showSuccessScreen {
                    successView
                } else {
                    loadingView
                        .onAppear {
                            onAppearLoadingView?()
                        }
                }
            }
        }
        .presentableStoreLensAnimation(.default)
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
                buttons: .init(
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
                .tint(hTextColor.primary)
                .frame(width: UIScreen.main.bounds.width * 0.53)
            Spacer()
            Spacer()
            Spacer()
        }
    }
}

class ProcessingViewModel: ObservableObject {
    @Published var progress: Float = 0
}
