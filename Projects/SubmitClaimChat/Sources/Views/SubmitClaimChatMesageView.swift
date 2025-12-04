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
                viewModel.resultView()
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

extension ClaimIntentStepHandler {
    func stepView() -> some View {
        VStack {
            if let viewModel = self as? SubmitClaimAudioStep {
                SubmitClaimAudioView(viewModel: viewModel)
            } else if let viewModel = self as? SubmitClaimSingleSelectStep {
                SubmitClaimSingleSelectView(viewModel: viewModel)
            } else if let viewModel = self as? SubmitClaimFormStep {
                SubmitClaimFormView(viewModel: viewModel)
            } else if let viewModel = self as? SubmitClaimSummaryStep {
                SubmitClaimSummaryBottomView(viewModel: viewModel)
            } else if let viewModel = self as? SubmitClaimFileUploadStep {
                SubmitClaimFileUploadView(viewModel: viewModel)
            } else if let viewModel = self as? SubmitClaimUnknownStep {
                SubmitClaimUnknownView(viewModel: viewModel)
            }
            if self.isSkippable {
                hButton(.large, .ghost, content: .init(title: "Skip")) { [weak self] in
                    Task {
                        await self?.skip()
                    }
                }
                .disabled(!self.isEnabled)
                .hButtonIsLoading(false)
            }
        }
        .disabled(!self.isEnabled)
    }

    @ViewBuilder
    func resultView() -> some View {
        VStack(alignment: .trailing, spacing: .padding4) {
            if self.isSkipped {
                hPill(text: "Skipped", color: .grey)
            } else if self.isStepExecuted || self is SubmitClaimTaskStep || self is SubmitClaimSummaryStep {
                if let viewModel = self as? SubmitClaimAudioStep {
                    SubmitClaimAudioResultView(viewModel: viewModel)
                } else if let viewModel = self as? SubmitClaimSingleSelectStep {
                    SubmitClaimSingleSelectResultView(viewModel: viewModel)
                } else if let viewModel = self as? SubmitClaimSummaryStep {
                    SubmitClaimSummaryView(viewModel: viewModel)
                } else if let viewModel = self as? SubmitClaimFileUploadStep {
                    SubmitClaimFileUploadResultView(viewModel: viewModel)
                } else if let viewModel = self as? SubmitClaimFormStep {
                    SubmitClaimFormResultView(viewModel: viewModel)
                } else if let viewModel = self as? SubmitClaimTaskStep {
                    SubmitClaimTaskResultView(viewModel: viewModel)
                }
            }
            if self.isRegrettable && self.isStepExecuted {
                hButton(.small, .ghost, content: .init(title: L10n.General.edit)) { [weak self] in
                    Task {
                        await self?.regret()
                    }
                }
            }
        }
    }
}
