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
        content
            .detent(
                presented: $viewModel.alertPresented,
                transitionType: .center
            ) {
                if let alertModel = viewModel.alertModel {
                    switch alertModel.type {
                    case .edit:
                        editAlert(model: alertModel)
                    case .error:
                        errorAlert(model: alertModel)
                    }
                }
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

    private func editAlert(model: SubmitClaimChatScreenAlertViewModel.AlertModel) -> some View {
        hForm {
            hSection {
                VStack(alignment: .leading, spacing: .padding10) {
                    Text(model.title)
                        .foregroundColor(hTextColor.Opaque.primary)
                        .font(.system(size: 17, weight: .semibold))
                    Text(model.message)
                        .foregroundColor(hTextColor.Opaque.primary)
                        .font(.system(size: 17, weight: .regular))
                        .padding(.bottom, .padding24)

                    Text(L10n.claimChatEditAnswerButton)
                        .foregroundColor(hSignalColor.Red.element)
                        .font(.system(size: 17, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .hPillStyle(color: .grey, colorLevel: .two)
                        .hFieldSize(.button)
                        .onTapGesture {
                            model.action()
                        }

                    Text(L10n.embarkGoBackButton)
                        .frame(maxWidth: .infinity)
                        .font(.system(size: 17, weight: .medium))
                        .hPillStyle(color: .grey)
                        .hFieldSize(.button)
                        .onTapGesture {
                            model.onClose()
                        }
                }
            }
            .padding(.vertical, .padding14)
            .padding(.top, .padding8)
            .accessibilityElement(children: .combine)
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
