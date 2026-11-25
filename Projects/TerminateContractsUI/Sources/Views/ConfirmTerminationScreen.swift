import SwiftUI
import TerminateContractsCore
import hCore
import hCoreUI

struct ConfirmTerminationScreen: View {
    @Environment(TerminationFlowNavigationViewModel.self) var terminationNavigationVm
    @Environment(NavigationRouter.self) var router
    @State private var authenticationErrorMessage: String?
    init() {}

    var body: some View {
        GenericErrorView(
            title: L10n.General.areYouSure,
            description: terminationText,
            formPosition: .compact,
            attachContentToBottom: true
        )
        .hStateViewButtonConfig(
            .init(
                actionButtonAttachedToBottom:
                    .init(
                        buttonTitle: L10n.terminationFlowConfirmButton,
                        buttonAction: {
                            confirmTermination()
                        }
                    ),
                dismissButton: .init(
                    buttonTitle: L10n.alertCancel,
                    buttonAction: {
                        router.dismiss()
                    }
                )
            )
        )
        .hExtraTopPadding
        .alert(
            L10n.generalError,
            isPresented: Binding(
                get: { authenticationErrorMessage != nil },
                set: { if !$0 { authenticationErrorMessage = nil } }
            ),
            presenting: authenticationErrorMessage
        ) { _ in
            Button(L10n.generalOkButton, role: .cancel) {}
        } message: { message in
            Text(message)
        }
    }

    private func confirmTermination() {
        Task {
            // Keep the confirmation sheet open if the user fails or cancels local authentication.
            do {
                try await Dependencies.localAuthenticator.authenticate(reason: L10n.localAuthReason)
                terminationNavigationVm.submitTermination()
                router.dismiss()
            } catch LocalAuthenticationError.cancelledByUser, LocalAuthenticationError.cancelledBySystem {
                // Cancelling isn't an error; the sheet stays open so the user can try again.
            } catch {
                authenticationErrorMessage = error.localizedDescription
            }
        }
    }

    var terminationText: String {
        if terminationNavigationVm.isDeletion {
            return L10n.terminationFlowConfirmation
        }
        return L10n.terminationFlowConfirmationSubtitleTermination(
            terminationNavigationVm.selectedDate?.displayDateDDMMMYYYYFormat ?? ""
        )
    }
}

#Preview {
    ConfirmTerminationScreen()
        .environment(TerminationFlowNavigationViewModel(configs: [], terminateInsuranceViewModel: nil))
}
