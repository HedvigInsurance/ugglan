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
        let message: String
        let action: () -> Void
        let onClose: () -> Void

        init(
            message: String,
            action: @escaping () -> Void,
            onClose: @escaping () -> Void = {}
        ) {
            self.message = message
            self.action = action
            self.onClose = onClose
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
        content
            .detent(
                presented: $viewModel.alertPresented,
                transitionType: .center
            ) {
                hForm {
                    hSection {
                        hCoreUIAssets.warningTriangleFilled.view
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(hSignalColor.Amber.element)
                            .accessibilityHidden(true)
                            .padding(.bottom, .padding16)
                        VStack(spacing: 0) {
                            hText(L10n.somethingWentWrong)
                                .foregroundColor(hTextColor.Opaque.primary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, .padding32)
                            hText(viewModel.alertModel?.message ?? "")
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
    }
}

extension View {
    func submitClaimChatScreenAlert(_ viewModel: SubmitClaimChatScreenAlertViewModel) -> some View {
        self.modifier(SubmitClaimChatScreenAlertHelper(viewModel: viewModel))
    }
}
