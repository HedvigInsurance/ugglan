import Claims
import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimChatMesageView: View {
    @ObservedObject var viewModel: ClaimIntentStepHandler

    @ViewBuilder
    var body: some View {
        VStack(alignment: .leading, spacing: .padding8) {
            hText(viewModel.claimIntent.currentStep.text)
            senderStamp(step: viewModel)
        }
        HStack {
            spacing(viewModel.sender == .member)
            VStack(alignment: .leading, spacing: .padding8) {
                Group {
                    if let viewModel = viewModel as? SubmitClaimAudioStep {
                        SubmitClaimAudioView(viewModel: viewModel)
                    } else if let viewModel = viewModel as? SubmitClaimSingleSelectStep {
                        SubmitClaimSingleSelectView(viewModel: viewModel)
                    } else if let viewModel = viewModel as? SubmitClaimFormStep {
                        SubmitClaimFormView(viewModel: viewModel)
                    } else if let viewModel = viewModel as? SubmitClaimSummaryStep {
                        SubmitClaimSummaryView(viewModel: viewModel)
                    } else if let viewModel = viewModel as? SubmitClaimTaskStep {
                        SubmitClaimTaskView(viewModel: viewModel)
                    } else if let viewModel = viewModel as? SubmitClaimOutcomeStep {
                        SubmitClaimOutcomeView(viewModel: viewModel)
                    } else if let viewModel = viewModel as? SubmitClaimFileUploadStep {
                        SubmitClaimFileUploadView(viewModel: viewModel)
                    } else if let viewModel = viewModel as? SubmitClaimUnknownStep {
                        SubmitClaimOnknownView(viewModel: viewModel)
                    }
                }
                .frame(
                    maxWidth: viewModel.maxWidth,
                    alignment: viewModel.alignment
                )
                if viewModel.isSkippable && viewModel.isEnabled {
                    skipButton
                }
            }
            .disabled(!viewModel.isEnabled)
            .hButtonIsLoading(viewModel.isLoading)
            .fixedSize(horizontal: false, vertical: true)
            spacing(viewModel.sender == .hedvig)

            if viewModel.isRegrettable && !viewModel.isEnabled {
                regretButton
            }
        }
        .id(viewModel.id)
    }

    private var skipButton: some View {
        hButton(.medium, .secondary, content: .init(title: "Skip")) {
            Task {
                try await viewModel.skip()
            }
        }
    }

    private var regretButton: some View {
        hCoreUIAssets.edit.view
            .onTapGesture {
                Task {
                    try await viewModel.regret()
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
        case .outcome, .summary, .singleSelect:
            return .infinity
        default:
            return 300
        }
    }

    var alignment: Alignment {
        if sender == .hedvig {
            switch claimIntent.currentStep.content {
            case .outcome:
                return .center
            default:
                return .leading
            }
        }
        return .trailing
    }
}
