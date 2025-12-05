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
                    primaryButton: .default(Text(L10n.generalRetry)) {
                        viewModel.submitResponse()
                    },
                    secondaryButton: .default(Text(L10n.generalCloseButton)) {
                        viewModel.isEnabled = true
                    }
                )
            }
    }
}

struct SubmitClaimChatScreenAlertHelper: ViewModifier {
    @ObservedObject var viewModel: SubmitClaimChatViewModel
    func body(content: Content) -> some View {
        content
            .alert(isPresented: $viewModel.showError) {
                Alert(
                    title: Text(L10n.somethingWentWrong),
                    message: Text(viewModel.error?.localizedDescription ?? ""),
                    primaryButton: .default(Text(L10n.generalRetry)) {
                        viewModel.startClaimIntent()
                    },
                    secondaryButton: .default(Text(L10n.generalCloseButton)) {
                        viewModel.router.dismiss()
                    }
                )
            }
    }
}
