import SwiftUI
import TagKit
import hCoreUI

struct SubmitClaimSingleSelectView: View {
    @EnvironmentObject var viewModel: SubmitClaimSingleSelectStep
    @EnvironmentObject var mainVM: SubmitClaimChatViewModel

    public var body: some View {
        TagList(tags: viewModel.options.compactMap({ $0.id })) { tag in
            hPill(
                text: viewModel.options.first(where: { $0.id == tag })?.title ?? "",
                color: viewModel.selectedOption == tag ? .green : .grey
            )
            .onTapGesture {
                withAnimation {
                    viewModel.selectedOption = tag
                }
            }
        }
        .disabled(!viewModel.isEnabled)
        if viewModel.selectedOption != nil && viewModel.isEnabled {
            hContinueButton {
                Task {
                    try await mainVM.submitStep(handler: viewModel)
                }
            }
        }
    }
}
