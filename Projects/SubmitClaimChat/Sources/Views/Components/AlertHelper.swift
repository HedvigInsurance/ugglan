import SwiftUI
import hCore

class SubmitClaimChatScreenAlertViewModel: ObservableObject {
    @Published var alertIsPresented: SubmitClaimAlertState?
    
    enum SubmitClaimAlertState: Identifiable {
        case global(model: SubmitClaimChatViewModel)
        case step(model: ClaimIntentStepHandler)
        
        var id: ObjectIdentifier {
            switch self {
            case let .global(model):
                return ObjectIdentifier(model)
            case let .step(model):
                return ObjectIdentifier(model)
            }
        }
        
        @MainActor
        var alert: Alert {
            switch self {
            case let .global(model):
                return Alert(
                    title: Text(L10n.somethingWentWrong),
                    message: Text(model.error?.localizedDescription ?? ""),
                    primaryButton: .default(Text(L10n.generalRetry)) {
                        model.startClaimIntent()
                    },
                    secondaryButton: .default(Text(L10n.generalCloseButton)) {
                        model.router.dismiss()
                    }
                )

            case let .step(model):
                return Alert(
                    title: Text(L10n.somethingWentWrong),
                    message: Text(model.state.error?.localizedDescription ?? ""),
                    primaryButton: .default(Text(L10n.generalRetry)) {
                        model.submitResponse()
                    },
                    secondaryButton: .default(Text(L10n.generalCloseButton)) {
                        model.state.isEnabled = true
                    }
                )
            }
        }
    }
}

struct SubmitClaimChatScreenAlertHelper: ViewModifier {
    @ObservedObject var viewModel: SubmitClaimChatScreenAlertViewModel
    
    func body(content: Content) -> some View {
        content
            .alert(item: $viewModel.alertIsPresented) { alertState in
                alertState.alert
            }
    }
}

extension View {
    func submitClaimChatScreenAlert(_ viewModel: SubmitClaimChatScreenAlertViewModel) -> some View {
        self.modifier(SubmitClaimChatScreenAlertHelper(viewModel: viewModel))
    }
}

