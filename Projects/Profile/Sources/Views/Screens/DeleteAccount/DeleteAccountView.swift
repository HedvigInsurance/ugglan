import Presentation
import SwiftUI
import hCore
import hCoreUI

struct DeleteAccountView: View {
    @ObservedObject var viewModel: DeleteAccountViewModel

    var body: some View {
        if viewModel.hasActiveClaims || viewModel.hasActiveContracts {
            InfoView(
                title: L10n.profileDeleteAccountFailed,
                description: L10n.profileDeleteAccountFailedLabel,
                onDismiss: {
//                    let store: UgglanStore = globalPresentableStoreContainer.get()
//                    store.send(.dismissScreen)
                },
                extraButton: (
                    text: L10n.openChat, style: .primary,
                    action: {
//                        let store: UgglanStore = globalPresentableStoreContainer.get()
//                        store.send(.dismissScreen)
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                            store.send(.openChat)
//                        }
                    }
                )
            )
        } else {
            InfoView(
                title: L10n.DeleteAccount.confirmationTitle,
                description: L10n.DeleteAccount.deletedDataDescription + "\n\n" + L10n.DeleteAccount.processingFooter,
                onDismiss: {
//                    let store: UgglanStore = globalPresentableStoreContainer.get()
//                    store.send(.dismissScreen)
                },
                extraButton: (
                    text: L10n.profileDeleteAccountConfirmDeleteion,
                    style: .alert,
                    action: {
                        viewModel.deleteAccount()
                    }
                )
            )
        }
    }
}

struct ParagraphTextModifier<Color: hColor>: ViewModifier {
    var color: Color

    func body(content: Content) -> some View {
        content
            .fixedSize(horizontal: false, vertical: true)
            .foregroundColor(color)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
