import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimChatMesageView: View {
    @ObservedObject var viewModel: ClaimIntentStepHandler
    @ViewBuilder
    var body: some View {
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
            } else {
                hText("--- \(String(describing: viewModel.self)) ---")
            }
        }
        .disabled(!viewModel.isEnabled)
        .hButtonIsLoading(viewModel.isLoading)
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
