import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimChatMesageView: View {
    @ObservedObject var viewModel: ClaimIntentStepHandler

    var body: some View {
        VStack(spacing: .padding8) {
            if let text = viewModel.getText() {
                HStack {
                    VStack(alignment: .leading, spacing: .padding8) {
                        RevealTextView(
                            text: text,
                            delay: 1,
                            animate: viewModel.state.animateText,
                            onTextAnimationDone: {
                                withAnimation {
                                    viewModel.state.showInput = true
                                }
                            }
                        )
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
            }

            HStack {
                spacing(viewModel.sender == .member)
                VStack(alignment: .trailing, spacing: .padding6) {
                    ClaimStepResultView(viewModel: viewModel)
                        .transition(.offset(x: 0, y: 100).combined(with: .opacity).animation(.default))
                }
                .animation(.easeInOut(duration: 0.2), value: viewModel.state.isStepExecuted)
                .animation(.easeInOut(duration: 0.2), value: viewModel.state.isSkipped)
                .animation(.easeInOut(duration: 0.2), value: viewModel.state.showResults)
                .frame(
                    maxWidth: viewModel.maxWidth,
                    alignment: viewModel.alignment
                )
                .hButtonIsLoading(viewModel.state.isLoading)
                .fixedSize(horizontal: false, vertical: true)
                spacing(viewModel.sender == .hedvig)
            }
            .padding(.top, .padding16)
            .id("result_\(viewModel.id)")
        }
    }

    @ViewBuilder
    func spacing(_ addSpacing: Bool) -> some View {
        if addSpacing { Spacer() }
    }
}

extension ClaimIntentStepHandler {
    var maxWidth: CGFloat {
        switch claimIntent.currentStep.content {
        case .summary, .singleSelect, .deflect, .audioRecording:
            return .infinity
        default:
            return 300
        }
    }

    var alignment: Alignment {
        if sender == .hedvig {
            switch claimIntent.currentStep.content {
            default:
                return .leading
            }
        }
        return .trailing
    }
}

struct ClaimStepView: View {
    @ObservedObject var viewModel: ClaimIntentStepHandler
    @EnvironmentObject var submitClaimChatViewModel: SubmitClaimChatViewModel

    var body: some View {
        VStack {
            if let viewModel = viewModel as? SubmitClaimAudioStep {
                SubmitClaimAudioView(viewModel: viewModel)
            } else if let viewModel = viewModel as? SubmitClaimSingleSelectStep {
                SubmitClaimSingleSelectView(viewModel: viewModel)
            } else if let viewModel = viewModel as? SubmitClaimFormStep {
                SubmitClaimFormView(viewModel: viewModel)
            } else if let viewModel = viewModel as? SubmitClaimSummaryStep {
                SubmitClaimSummaryBottomView(viewModel: viewModel)
            } else if let viewModel = viewModel as? SubmitClaimFileUploadStep {
                SubmitClaimFileUploadView(viewModel: viewModel)
            } else if let viewModel = viewModel as? SubmitClaimUnknownStep {
                SubmitClaimUnknownView(viewModel: viewModel)
            } else if let viewModel = viewModel as? SubmitClaimDeflectStep {
                SubmitClaimDeflectStepView(model: viewModel.deflectModel)
            }
            if viewModel.isSkippable && !viewModel.state.disableSkip {
                hButton(.large, .ghost, content: .init(title: L10n.claimChatSkipStep)) { [weak viewModel] in
                    Task {
                        await viewModel?.skip()
                    }
                }
                .hButtonIsLoading(false)
                .accessibilityLabel(L10n.claimChatSkipStep)
                .accessibilityHint(L10n.generalContinueButton)
            }
        }
        .disabled(!viewModel.state.isEnabled)
        .animation(.easeInOut(duration: 0.2), value: viewModel.state.isEnabled)
        .animation(.easeInOut(duration: 0.2), value: viewModel.state.isLoading)
        .id("step_\(viewModel.id)")
    }
}
struct ClaimStepResultView: View {
    @ObservedObject var viewModel: ClaimIntentStepHandler
    @EnvironmentObject var chatViewModel: SubmitClaimChatViewModel
    @EnvironmentObject var alertVm: SubmitClaimChatScreenAlertViewModel

    @ViewBuilder var body: some View {
        if viewModel.state.isSkipped {
            hPill(text: L10n.claimChatSkippedLabel, color: .grey, colorLevel: .two, withBorder: false)
                .hFieldSize(.capsuleShape)
                .accessibilityLabel(L10n.claimChatSkippedLabel)
        } else if viewModel.state.showResults {
            if let viewModel = viewModel as? SubmitClaimAudioStep {
                SubmitClaimAudioResultView(viewModel: viewModel)
            } else if let viewModel = viewModel as? SubmitClaimSingleSelectStep {
                SubmitClaimSingleSelectResultView(viewModel: viewModel)
            } else if let viewModel = viewModel as? SubmitClaimSummaryStep {
                SubmitClaimSummaryView(viewModel: viewModel)
            } else if let viewModel = viewModel as? SubmitClaimFileUploadStep {
                SubmitClaimFileUploadResultView(viewModel: viewModel.fileUploadVm.fileGridViewModel)
            } else if let viewModel = viewModel as? SubmitClaimFormStep {
                SubmitClaimFormResultView(viewModel: viewModel)
            } else if let viewModel = viewModel as? SubmitClaimTaskStep {
                SubmitClaimTaskResultView(viewModel: viewModel)
            }
        }
        if viewModel.isRegrettable && viewModel.state.isStepExecuted {
            hPill(
                text: L10n.General.edit,
                color: .grey,
                colorLevel: .two,
                withBorder: false
            )
            .hFieldSize(.capsuleShape)
            .hPillAttributes(attributes: [.withChevron])
            .accessibilityLabel(L10n.General.edit)
            .accessibilityHint(L10n.voiceoverEdit)
            .accessibilityAddTraits(.isButton)
            .onTapGesture { [weak viewModel] in
                alertVm.alertModel = .init(
                    type: .edit,
                    message: L10n.claimChatEditExplanation,
                    action: {
                        Task {
                            await viewModel?.regret()
                            alertVm.alertModel = nil
                        }
                    },
                    onClose: {
                        alertVm.alertModel = nil
                    }
                )
            }
        }
    }
}
