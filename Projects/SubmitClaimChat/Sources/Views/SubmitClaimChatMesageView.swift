import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimChatMesageView: View {
    @ObservedObject var viewModel: ClaimIntentStepHandler
    let animationNamespace: Namespace.ID

    var body: some View {
        Group {
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: .padding8) {
                        hText(viewModel.claimIntent.currentStep.text)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    if viewModel.isRegrettable && !viewModel.isEnabled {
                        regretButton
                    }
                }
                HStack {
                    spacing(viewModel.sender == .member)
                    VStack(alignment: .leading, spacing: .padding8) {
                        viewModel.stepView2(namespace: animationNamespace)
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
            }
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
    func stepView(namespace: Namespace.ID) -> some View {
        VStack {
            if let viewModel = self as? SubmitClaimAudioStep {
                SubmitClaimAudioView(viewModel: viewModel)
            } else if let viewModel = self as? SubmitClaimSingleSelectStep {
                SubmitClaimSingleSelectView(viewModel: viewModel, animationNamespace: namespace)
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

    @ViewBuilder
    func stepView2(namespace: Namespace.ID) -> some View {
        if !self.isEnabled && !self.isLoading {
            //        if let viewModel = self as? SubmitClaimAudioStep {
            //            SubmitClaimAudioView(viewModel: viewModel)
            //        } else
            if let viewModel = self as? SubmitClaimSingleSelectStep {
                SubmitClaimSingleSelectView2(viewModel: viewModel, animationNamespace: namespace)
            }
            //        else if let viewModel = self as? SubmitClaimFormStep {
            //            SubmitClaimFormView(viewModel: viewModel)
            //        } else if let viewModel = self as? SubmitClaimSummaryStep {
            //            SubmitClaimSummaryView(viewModel: viewModel)
            //        } else if let viewModel = self as? SubmitClaimTaskStep {
            //            SubmitClaimTaskView(viewModel: viewModel)
            //        } else if let viewModel = self as? SubmitClaimFileUploadStep {
            //            SubmitClaimFileUploadView(viewModel: viewModel)
            //        } else if let viewModel = self as? SubmitClaimUnknownStep {
            //            SubmitClaimUnknownView(viewModel: viewModel)
            //        }
        }
    }
}
