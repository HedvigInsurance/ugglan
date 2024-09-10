import Foundation
import PresentableStore
import SwiftUI
import hCore

public struct hProcessingView<S: Store & StoreLoading>: View {
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

    var errorViewButtons: ErrorViewButtonConfig?
    @Environment(\.hSuccessBottomAttachedView) var successBottomView
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
        }
        .presentableStoreLensAnimation(.default)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
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
