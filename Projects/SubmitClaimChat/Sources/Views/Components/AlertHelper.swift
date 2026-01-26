import SwiftUI
import hCore
import hCoreUI

@MainActor
class SubmitClaimChatScreenAlertViewModel: ObservableObject {
    var alertModel: AlertModel? {
        didSet {
            switch alertModel?.type {
            case .edit: systemAlertPresented = true
            case .error: alertPresentationModel = alertModel
            case .none: break
            }
        }
    }

    @Published fileprivate var alertPresentationModel: AlertModel?
    @Published fileprivate var systemAlertPresented = false

    struct AlertModel: Identifiable, Equatable {
        public static func == (lhs: AlertModel, rhs: AlertModel) -> Bool {
            lhs.id == rhs.id
        }

        let id: String
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
            self.id = UUID().uuidString
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
}

struct SubmitClaimChatScreenAlertHelper: ViewModifier {
    @ObservedObject var viewModel: SubmitClaimChatScreenAlertViewModel

    func body(content: Content) -> some View {
        content
            .detent(
                item: $viewModel.alertPresentationModel,
                transitionType: .center,
                options: .constant(.alwaysOpenOnTop),
                onUserDismiss: { [weak viewModel] in
                    viewModel?.alertPresentationModel?.onClose()
                }
            ) { alertModel in
                //                errorAlert(model: alertModel)
                hForm {
                    hSection {
                        warningTriangleImage
                        VStack(spacing: 0) {
                            hText(alertModel.title)
                                .foregroundColor(hTextColor.Opaque.primary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, .padding32)
                            hText(alertModel.message)
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
                            self.viewModel.alertPresentationModel = nil
                            alertModel.action()
                        }
                    }
                }
                .hFormContentPosition(.center)
                .sectionContainerStyle(.transparent)
            }
            .alert(isPresented: $viewModel.systemAlertPresented) {
                Alert(
                    title: Text(viewModel.alertModel?.title ?? "").font(.system(size: 17, weight: .semibold)),
                    message: Text(viewModel.alertModel?.message ?? "").font(.system(size: 17, weight: .regular)),
                    primaryButton: .destructive(
                        Text(L10n.claimChatEditAnswerButton).font(.system(size: 17, weight: .medium)),
                        action: { [weak viewModel] in
                            viewModel?.alertModel?.action()
                        }
                    ),
                    secondaryButton: .default(
                        Text(L10n.generalCancelButton).font(.system(size: 17, weight: .medium))
                    ) { [weak viewModel] in
                        viewModel?.alertModel?.onClose()
                    }
                )
            }
    }

    //    private func errorAlert(model: SubmitClaimChatScreenAlertViewModel.AlertModel) -> some View {
    //        hForm {
    //            hSection {
    //                warningTriangleImage
    //                VStack(spacing: 0) {
    //                    hText(model.title)
    //                        .foregroundColor(hTextColor.Opaque.primary)
    //                        .multilineTextAlignment(.center)
    //                        .padding(.horizontal, .padding32)
    //                    hText(model.message)
    //                        .foregroundColor(hTextColor.Translucent.secondary)
    //                        .multilineTextAlignment(.center)
    //                        .padding(.horizontal, .padding32)
    //                }
    //            }
    //            .padding(.vertical, 80)
    //            .accessibilityElement(children: .combine)
    //        }
    //        .hFormAttachToBottom {
    //            hSection {
    //                hButton(.large, .primary, content: .init(title: L10n.generalRetry)) {
    //                    self.viewModel.alertPresentationModel = nil
    //                    model.action()
    //                }
    //            }
    //        }
    //        .hFormContentPosition(.center)
    //        .sectionContainerStyle(.transparent)
    //    }

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
