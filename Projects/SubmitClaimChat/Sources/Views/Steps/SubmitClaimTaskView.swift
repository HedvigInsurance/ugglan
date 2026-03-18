import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimTaskResultView: View {
    @ObservedObject var viewModel: SubmitClaimTaskStep
    @State private var isLoading = true

    var body: some View {
        HStack(spacing: .padding4) {
            ClaimChatLoadingAnimationView(isLoading: $isLoading)
                .frame(
                    width: ClaimChatLoadingAnimationView.Constants.animationSize,
                    height: ClaimChatLoadingAnimationView.Constants.animationSize
                )
                // Compensate for Rive asset internal padding
                .padding(.horizontal, -.padding2)
            hText(viewModel.taskModel.description, style: .body1)
                .animation(.easeInOut, value: viewModel.taskModel)
        }
        .clipped()
        // Offset to align with chat message content above
        .padding(.top, -.padding16)
        .transition(.opacity.animation(.easeOut))
        .animation(.easeInOut, value: viewModel.taskModel)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(L10n.claimChatTaskContentDescription)
        .onChange(of: viewModel.taskModel.isCompleted) { completed in
            if completed {
                isLoading = false
            }
        }
    }
}

#Preview {
    let demo = ClaimIntentClientDemo()
    Dependencies.shared.add(module: Module { () -> ClaimIntentClient in demo })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    let model = ClaimIntentClientDemo().taskDemoStep
    return SubmitClaimTaskResultView(viewModel: model)
}
