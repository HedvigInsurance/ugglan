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
            if let displayText = viewModel.displayText {
                hText(displayText, style: .body1)
                    .modifier(ShimmerTextModifier(isActive: true))
                    .transition(.opacity)
            }
        }
        // Offset to align with chat message content above
        .padding(.top, -.padding16)
        // Offset to align with chat message content below
        .padding(.bottom, -.padding8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(L10n.claimChatTaskContentDescription)
        .animation(.easeInOut(duration: 0.3), value: viewModel.displayText)
    }
}

#Preview {
    let demo = ClaimIntentClientDemo()
    Dependencies.shared.add(module: Module { () -> ClaimIntentClient in demo })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    let model = demo.taskDemoStep
    return VStack(alignment: .leading) {
        SubmitClaimTaskResultView(viewModel: model)
    }
}
