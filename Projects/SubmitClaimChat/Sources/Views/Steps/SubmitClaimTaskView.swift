import SwiftUI
import hCore
import hCoreUI

struct SubmitClaimTaskResultView: View {
    @ObservedObject var viewModel: SubmitClaimTaskStep

    var body: some View {
        HStack(spacing: .padding4) {
            ClaimChatLoadingAnimationView(
                isLoading: $viewModel.state.isLoaderAnimating
            )
            .frame(
                width: ClaimChatLoadingAnimationView.Constants.animationSize,
                height: ClaimChatLoadingAnimationView.Constants.animationSize
            )
            //Compensate for Rive asset internal padding
            .padding(.horizontal, -.padding2)
            if viewModel.taskModel.description != "" {
                hText(viewModel.taskModel.description, style: .body1)
                    .modifier(ShimmerModifier(isActive: true))
                    .transition(.opacity)
                    .animation(.easeInOut, value: viewModel.taskModel)
            }
        }
        // Offset to align with chat message content above
        .padding(.top, -.padding16)
        // Offset to align with chat message content below
        .padding(.bottom, -.padding8)
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
    return VStack(alignment: .leading) {
        SubmitClaimTaskResultView(viewModel: model)
    }
}
