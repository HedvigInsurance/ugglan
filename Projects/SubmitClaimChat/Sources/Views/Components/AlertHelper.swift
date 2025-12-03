import SwiftUI
import hCore

struct AlertHelper: ViewModifier {
    @ObservedObject var viewModel: ClaimIntentStepHandler
    func body(content: Content) -> some View {
        content
            .alert(isPresented: $viewModel.showError) {
                Alert(
                    title: Text(L10n.somethingWentWrong),
                    message: Text(viewModel.error?.localizedDescription ?? ""),
                    primaryButton: .default(Text(L10n.generalRetry)) { [weak viewModel] in
                        Task {
                            await viewModel?.submitResponse()
                        }
                    },
                    secondaryButton: .default(Text(L10n.generalCloseButton)) { [weak viewModel] in
                        viewModel?.isEnabled = true
                    }
                )
            }
    }
}
