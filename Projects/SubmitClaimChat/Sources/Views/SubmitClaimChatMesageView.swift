import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimChatMesageView: View {
    let step: any ClaimIntentStepHandler

    @ViewBuilder
    var body: some View {
        if let step = step as? SubmitClaimAudioStep {
            SubmitClaimAudioView()
                .environmentObject(step)
        } else if let step = step as? SubmitClaimSingleSelectStep {
            SubmitClaimSingleSelectView()
                .environmentObject(step)
        } else if let step = step as? SubmitClaimFormStep {
            SubmitClaimFormView()
                .environmentObject(step)
        } else {
            hText("--- \(String(describing: step.self)) ---")
        }
    }
}
