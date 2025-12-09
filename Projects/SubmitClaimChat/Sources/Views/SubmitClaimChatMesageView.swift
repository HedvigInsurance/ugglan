import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimChatMesageView: View {
    @ObservedObject var viewModel: ClaimIntentStepHandler

    var body: some View {
        VStack(spacing: .padding8) {
            if viewModel.showText {
                HStack {
                    VStack(alignment: .leading, spacing: .padding8) {
                        RevealTextView(
                            text: viewModel.claimIntent.currentStep.text,
                            delay: 1
                        )
                    }

                    .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
            }

            if let viewModel = viewModel as? SubmitClaimAudioStep {
                HStack {
                    RevealTextView(
                        text: viewModel.audioRecordingModel.hint,
                        delay: 2,
                        showDot: false
                    )
                    Spacer()
                }
            }

            HStack {
                spacing(viewModel.sender == .member)
                VStack(alignment: .trailing, spacing: .padding4) {
                    ClaimStepResultView(viewModel: viewModel)
                        .transition(.offset(x: 0, y: 100).combined(with: .opacity).animation(.default))
                }
                .animation(.easeInOut(duration: 0.2), value: viewModel.isStepExecuted)
                .animation(.easeInOut(duration: 0.2), value: viewModel.isSkipped)
                .animation(.easeInOut(duration: 0.2), value: viewModel.showResults)
                .frame(
                    maxWidth: viewModel.maxWidth,
                    alignment: viewModel.alignment
                )
                .hButtonIsLoading(viewModel.isLoading)
                .fixedSize(horizontal: false, vertical: true)
                .id("result_\(viewModel.id)")
                spacing(viewModel.sender == .hedvig)
            }
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
        case .summary, .singleSelect:
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
            }
            if viewModel.isSkippable {
                hButton(.large, .ghost, content: .init(title: "Skip")) { [weak viewModel] in
                    Task {
                        await viewModel?.skip()
                    }
                }
                .hButtonIsLoading(false)
            }
        }
        .disabled(!viewModel.isEnabled)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isEnabled)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isLoading)
    }
}
struct ClaimStepResultView: View {
    @ObservedObject var viewModel: ClaimIntentStepHandler
    @ViewBuilder
    var body: some View {
        if viewModel.isSkipped {
            hPill(text: "Skipped", color: .grey)
        } else if viewModel.showResults {
            if let viewModel = viewModel as? SubmitClaimAudioStep {
                SubmitClaimAudioResultView(viewModel: viewModel)
            } else if let viewModel = viewModel as? SubmitClaimSingleSelectStep {
                SubmitClaimSingleSelectResultView(viewModel: viewModel)
            } else if let viewModel = viewModel as? SubmitClaimSummaryStep {
                SubmitClaimSummaryView(viewModel: viewModel)
            } else if let viewModel = viewModel as? SubmitClaimFileUploadStep {
                SubmitClaimFileUploadResultView(viewModel: viewModel)
            } else if let viewModel = viewModel as? SubmitClaimFormStep {
                SubmitClaimFormResultView(viewModel: viewModel)
            } else if let viewModel = viewModel as? SubmitClaimTaskStep {
                SubmitClaimTaskResultView(viewModel: viewModel)
            }
        }
        if viewModel.isRegrettable && viewModel.isStepExecuted {
            hButton(.small, .ghost, content: .init(title: L10n.General.edit)) { [weak viewModel] in
                Task {
                    await viewModel?.regret()
                }
            }
        }
    }
}
