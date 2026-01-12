import SwiftUI
import hCore
import hCoreUI

@MainActor
class SubmitClaimChatScreenAlertViewModel: ObservableObject {
    var alertModel: AlertModel? {
        didSet {
            alertPresented = alertModel != nil
        }
    }
    @Published var alertPresented = false {
        didSet {
            if alertPresented == false {
                self.handleClose()
            }
        }
    }

    struct AlertModel {
        let type: AlertType
        let message: String
        let action: () -> Void
        let onClose: () -> Void

        init(
            type: AlertType,
            message: String,
            action: @escaping () -> Void,
            onClose: @escaping () -> Void = {}
        ) {
            self.type = type
            self.message = message
            self.action = action
            self.onClose = onClose
        }

        var title: String {
            switch type {
            case .edit:
                return L10n.claimChatEditTitle
            case .error:
                return L10n.somethingWentWrong
            }
        }

        var spacing: CGFloat {
            switch type {
            case .edit:
                return .padding10
            case .error:
                return 0
            }
        }

        var alignment: HorizontalAlignment {
            switch type {
            case .edit:
                return .leading
            case .error:
                return .center
            }
        }

        enum AlertType {
            case error
            case edit
        }
    }
    enum SubmitClaimAlertState {
        case global(model: SubmitClaimChatViewModel)
        case step(model: ClaimIntentStepHandler)
    }

    func handleTryAgain() {
        if let alertModel = alertModel {
            alertModel.action()
            self.alertModel = nil
        }
    }

    func handleClose() {
        if let alertModel = alertModel {
            alertModel.onClose()
            self.alertModel = nil
        }
    }
}

struct SubmitClaimChatScreenAlertHelper: ViewModifier {
    @ObservedObject var viewModel: SubmitClaimChatScreenAlertViewModel

    func body(content: Content) -> some View {

        switch viewModel.alertModel?.type {
        case .edit:
            content
                .alert(isPresented: $viewModel.alertPresented) {
                    Alert(
                        title: Text(viewModel.alertModel?.title ?? "").font(.system(size: 17, weight: .semibold)),
                        message: Text(viewModel.alertModel?.message ?? "").font(.system(size: 17, weight: .regular)),
                        primaryButton: .destructive(
                            Text(L10n.claimChatEditAnswerButton).font(.system(size: 17, weight: .medium)),
                            action: {
                                viewModel.alertModel?.action()
                            }
                        ),
                        secondaryButton: .default(
                            Text(L10n.embarkGoBackButton).font(.system(size: 17, weight: .medium)),
                            action: {
                                viewModel.alertModel?.action()
                            }
                        )
                    )
                }
        case .error:
            content
                .detent(
                    presented: $viewModel.alertPresented,
                    transitionType: .center
                ) {
                    if let alertModel = viewModel.alertModel {
                        errorAlert(model: alertModel)
                    }
                }
        case .none:
            content
        }
    }

    private func errorAlert(model: SubmitClaimChatScreenAlertViewModel.AlertModel) -> some View {
        hForm {
            hSection {
                warningTriangleImage
                VStack(spacing: 0) {
                    hText(model.title)
                        .foregroundColor(hTextColor.Opaque.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, .padding32)
                    hText(model.message)
                        .foregroundColor(hTextColor.Translucent.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, .padding32)
                }
            }
            .padding(.vertical, 80)
            .accessibilityElement(children: .combine)
        }
        .hFormAttachToBottom {
            hSection {
                hButton(.large, .primary, content: .init(title: L10n.generalRetry)) {
                    viewModel.handleTryAgain()
                }
            }
        }
        .hFormContentPosition(.center)
        .sectionContainerStyle(.transparent)
    }

    private var warningTriangleImage: some View {
        hCoreUIAssets.warningTriangleFilled.view
            .resizable()
            .frame(width: 40, height: 40)
            .foregroundColor(hSignalColor.Amber.element)
            .accessibilityHidden(true)
            .padding(.bottom, .padding16)
    }
}

extension View {
    func submitClaimChatScreenAlert(_ viewModel: SubmitClaimChatScreenAlertViewModel) -> some View {
        self.modifier(SubmitClaimChatScreenAlertHelper(viewModel: viewModel))
    }
}
