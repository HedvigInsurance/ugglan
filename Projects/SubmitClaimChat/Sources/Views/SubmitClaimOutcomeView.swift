import SwiftUI
import hCoreUI

struct SubmitClaimOutcomeView: View {
    @EnvironmentObject var viewModel: SubmitClaimOutcomeStep
    @EnvironmentObject var mainVM: SubmitClaimChatViewModel

    var body: some View {
        VStack(spacing: .padding16) {
            hButton(.medium, .secondary, content: .init(title: "Go to claim")) {
                mainVM.goToClaimDetails(viewModel.claimIntent.id)
            }
        }
    }
}
