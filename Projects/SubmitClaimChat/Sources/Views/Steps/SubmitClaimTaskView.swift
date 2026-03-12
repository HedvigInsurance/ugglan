import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimTaskResultView: View {
    @ObservedObject var viewModel: SubmitClaimTaskStep
    var body: some View {
        HStack(spacing: .padding4) {
            HedvigRiveAnimationView(isAnimating: $viewModel.taskModel.isCompleted)
                .frame(width: 36, height: 36)
                .padding(.horizontal, -.padding2)
            hText(viewModel.taskModel.description, style: .body1)
                .animation(.easeInOut, value: viewModel.taskModel)
        }
        .clipped()
        .padding(.top, -.padding16)
        .transition(.opacity.animation(.easeOut))
        .animation(.easeInOut, value: viewModel.taskModel)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(L10n.claimChatTaskContentDescription)
    }
}

#Preview {
    let demo = ClaimIntentClientDemo()
    Dependencies.shared.add(module: Module { () -> ClaimIntentClient in demo })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    let model = ClaimIntentClientDemo().taskDemoStep
    return SubmitClaimTaskResultView(viewModel: model)
}
