import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimChatMesageView: View {
    @ObservedObject var viewModel: ClaimIntentStepHandler

    @ViewBuilder
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: .padding8) {
                hText(viewModel.claimIntent.currentStep.text)
                senderStamp(step: viewModel)
            }
            Spacer()
            if viewModel.isRegrettable && !viewModel.isEnabled {
                regretButton
            }
        }
        HStack {
            spacing(viewModel.sender == .member)
            VStack(alignment: .leading, spacing: .padding8) {
                Group {
                    viewModel.stepView
                    if viewModel.isSkippable && viewModel.isEnabled {
                        skipButton
                    }
                }
                .frame(
                    maxWidth: viewModel.maxWidth,
                    alignment: viewModel.alignment
                )
            }
            .disabled(!viewModel.isEnabled)
            .hButtonIsLoading(viewModel.isLoading)
            .trackError(for: $viewModel.error)
            .hStateViewButtonConfig(
                .init(
                    actionButton: .init(
                        buttonAction: { [weak viewModel] in
                            withAnimation {
                                viewModel?.isEnabled = true
                                viewModel?.error = nil
                                viewModel?.isLoading = false
                            }
                        })
                )
            )
            .fixedSize(horizontal: false, vertical: true)
            spacing(viewModel.sender == .hedvig)
        }
        .id(viewModel.id)
    }

    @ViewBuilder
    private func stepContentView() -> some View {
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
        } else if let viewModel = viewModel as? SubmitClaimFileUploadStep {
            SubmitClaimFileUploadView(viewModel: viewModel)
        } else if let viewModel = viewModel as? SubmitClaimUnknownStep {
            SubmitClaimUnknownView(viewModel: viewModel)
        }
    }

    private var skipButton: some View {
        hButton(.medium, .secondary, content: .init(title: "Skip")) {
            Task {
                await viewModel.skip()
            }
        }
        .disabled(!viewModel.isEnabled)
    }

    private var regretButton: some View {
        hCoreUIAssets.edit.view
            .onTapGesture {
                Task {
                    await viewModel.regret()
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
    @ViewBuilder
    var stepView: some View {
        if let viewModel = self as? SubmitClaimAudioStep {
            SubmitClaimAudioView(viewModel: viewModel)
        } else if let viewModel = self as? SubmitClaimSingleSelectStep {
            SubmitClaimSingleSelectView(viewModel: viewModel)
        } else if let viewModel = self as? SubmitClaimFormStep {
            SubmitClaimFormView(viewModel: viewModel)
        } else if let viewModel = self as? SubmitClaimSummaryStep {
            SubmitClaimSummaryView(viewModel: viewModel)
        } else if let viewModel = self as? SubmitClaimTaskStep {
            SubmitClaimTaskView(viewModel: viewModel)
        } else if let viewModel = self as? SubmitClaimFileUploadStep {
            SubmitClaimFileUploadView(viewModel: viewModel)
        } else if let viewModel = self as? SubmitClaimUnknownStep {
            SubmitClaimUnknownView(viewModel: viewModel)
        }
    }
}
