import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimChatMesageView: View {
    var step: any ClaimIntentStepHandler
    @ViewBuilder
    var body: some View {
        Group {
            if let step = step as? SubmitClaimAudioStep {
                SubmitClaimAudioView()
                    .environmentObject(step)
            } else if let step = step as? SubmitClaimSingleSelectStep {
                SubmitClaimSingleSelectView()
                    .environmentObject(step)
            } else if let step = step as? SubmitClaimFormStep {
                SubmitClaimFormView()
                    .environmentObject(step)
            } else if let step = step as? SubmitClaimSummaryStep {
                SubmitClaimSummaryView()
                    .environmentObject(step)
            } else {
                hText("--- \(String(describing: step.self)) ---")
            }
        }
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
