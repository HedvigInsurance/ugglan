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
                            text: viewModel.claimIntent.currentStep.text
                        )
                    }

                    .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
            }

            HStack {
                spacing(viewModel.sender == .member)
                ClaimStepResultView(viewModel: viewModel)
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

    @ViewBuilder
    func senderStamp(step: ClaimIntentStepHandler) -> some View {
        if step.isLoading {
            loadingView
        } else {
            HStack {
                Circle()
                    .frame(width: 16, height: 16)
                    .foregroundColor(hSignalColor.Green.element)
                hText("Hedvig AI Assistant", style: .label)
                    .foregroundColor(hTextColor.Opaque.secondary)
            }
        }
    }

    private var loadingView: some View {
        HStack { DotsActivityIndicator(.standard) }
            .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
            .padding(.horizontal, .padding16)
            .background(hBackgroundColor.primary.opacity(0.01))
            .edgesIgnoringSafeArea(.top)
            .useDarkColor
            .transition(.opacity.combined(with: .opacity).animation(.easeInOut(duration: 0.2)))
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
    }
}
struct ClaimStepResultView: View {
    @ObservedObject var viewModel: ClaimIntentStepHandler
    var body: some View {
        VStack(alignment: .trailing, spacing: .padding4) {
            if viewModel.isSkipped {
                hPill(text: "Skipped", color: .grey)
            } else if viewModel.isStepExecuted || viewModel is SubmitClaimTaskStep
                || viewModel is SubmitClaimSummaryStep
            {
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
}
