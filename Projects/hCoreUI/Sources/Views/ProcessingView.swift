import Presentation
import SwiftUI
import hCore

public struct ProcessingView<S: Store & StoreLoading, T>: View where T: View {
    @StateObject var vm = ProcessingViewModel()
    var showSuccessScreen: Bool
    var store: S.Type
    var loading: S.Loading

    var loadingViewText: String
    var successViewTitle: String?
    var successViewBody: String?
    var successViewButtonAction: (() -> Void)?

    var onAppearLoadingView: (() -> Void)?
    var onErrorCancelAction: (() -> Void)?
    var onLoadingDismiss: (() -> Void)?

    var customBottomSuccessView: T?
    var errorViewButtons: ErrorViewButtonConfig?

    public init(
        showSuccessScreen: Bool? = true,
        _ storeType: S.Type,
        loading: S.Loading,
        loadingViewText: String,
        successViewTitle: String? = nil,
        successViewBody: String? = nil,
        successViewButtonAction: (() -> Void)? = nil,
        onAppearLoadingView: (() -> Void)? = nil,
        onErrorCancelAction: (() -> Void)? = nil,
        onLoadingDismiss: (() -> Void)? = nil,
        customBottomSuccessView: T? = nil,
        errorViewButtons: ErrorViewButtonConfig? = nil
    ) {
        self.showSuccessScreen = showSuccessScreen ?? true
        self.store = storeType
        self.loading = loading
        self.loadingViewText = loadingViewText
        self.successViewTitle = successViewTitle
        self.successViewBody = successViewBody
        self.successViewButtonAction = successViewButtonAction
        self.onAppearLoadingView = onAppearLoadingView
        self.onErrorCancelAction = onErrorCancelAction
        self.onLoadingDismiss = onLoadingDismiss
        self.customBottomSuccessView = customBottomSuccessView
        self.errorViewButtons = errorViewButtons
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
                    SuccessScreen(
                        successViewTitle: successViewTitle ?? "",
                        successViewBody: successViewBody ?? "",
                        customBottomSuccessView: customBottomSuccessView,
                        successViewButtonAction: successViewButtonAction ?? {}
                    )
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

    //    private var successView: some View {
    //        ZStack(alignment: .bottom) {
    //            BackgroundView().ignoresSafeArea()
    //            VStack {
    //                Spacer()
    //                Spacer()
    //                VStack(spacing: 16) {
    //                    Image(uiImage: hCoreUIAssets.tick.image)
    //                        .resizable()
    //                        .frame(width: 24, height: 24)
    //                        .foregroundColor(hSignalColor.greenElement)
    //                    VStack(spacing: 0) {
    //                        hText(successViewTitle ?? "")
    //                        hText(successViewBody ?? "")
    //                            .foregroundColor(hTextColor.secondary)
    //                            .multilineTextAlignment(.center)
    //                    }
    //                    .padding(.horizontal, 16)
    //                }
    //                Spacer()
    //                Spacer()
    //                Spacer()
    //            }
    //            if customBottomSuccessView != nil {
    //                customBottomSuccessView
    //            } else {
    //                hSection {
    //                    VStack(spacing: 8) {
    //                        hButton.LargeButton(type: .ghost) {
    //                            successViewButtonAction?()
    //                        } content: {
    //                            hText(L10n.generalCloseButton)
    //                        }
    //                    }
    //                }
    //                .sectionContainerStyle(.transparent)
    //            }
    //        }
    //    }

    private var errorView: some View {
        ZStack(alignment: .bottom) {
            BackgroundView().ignoresSafeArea()
            GenericErrorView(
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

class ProcessingViewModel: ObservableObject {
    @Published var progress: Float = 0
}
