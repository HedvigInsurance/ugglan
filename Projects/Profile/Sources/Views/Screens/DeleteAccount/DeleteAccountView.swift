import Claims
import Contracts
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct DeleteAccountView: View {
    @ObservedObject var viewModel: DeleteAccountViewModel

    var body: some View {
        if viewModel.hasActiveClaims || viewModel.hasActiveContracts {
            InfoView(
                title: L10n.profileDeleteAccountFailed,
                description: L10n.profileDeleteAccountFailedLabel,
                onDismiss: {
                    let store: ProfileStore = globalPresentableStoreContainer.get()
                    store.send(.dismissScreen)
                },
                extraButton: (
                    text: L10n.openChat, style: .primary,
                    action: {
                        let store: ProfileStore = globalPresentableStoreContainer.get()
                        store.send(.dismissScreen)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            store.send(.openChat)
                        }
                    }
                )
            )
        } else {
            InfoView(
                title: L10n.DeleteAccount.confirmationTitle,
                description: L10n.DeleteAccount.deletedDataDescription + "\n\n" + L10n.DeleteAccount.processingFooter,
                onDismiss: {
                    let store: ProfileStore = globalPresentableStoreContainer.get()
                    store.send(.dismissScreen)
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

extension DeleteAccountView {
    static func deleteAccountJourney(details: MemberDetails) -> some JourneyPresentation {
        let claimsStore: ClaimsStore = globalPresentableStoreContainer.get()
        let contractsStore: ContractStore = globalPresentableStoreContainer.get()

        return HostingJourney(
            ProfileStore.self,
            rootView: DeleteAccountView(
                viewModel: DeleteAccountViewModel(
                    memberDetails: details,
                    claimsStore: claimsStore,
                    contractsStore: contractsStore
                )
            ),
            style: .detented(.scrollViewContentSize),
            options: [.blurredBackground]
        ) { action in
            if case let .sendAccountDeleteRequest(memberDetails) = action {
                sendAccountDeleteRequestJourney(details: memberDetails)
            } else if case .dismissScreen = action {
                PopJourney()
            }
        }
    }

    static func sendAccountDeleteRequestJourney(details: MemberDetails) -> some JourneyPresentation {
        HostingJourney(
            ProfileStore.self,
            rootView: DeleteRequestLoadingView(screenState: .sendingMessage(details)),
            style: .modally(presentationStyle: .fullScreen)
        ) { action in
            if case .makeTabActive = action {
                DismissJourney()
            }
        }
    }

    static var deleteRequestAlreadyPlacedJourney: some JourneyPresentation {
        HostingJourney(
            ProfileStore.self,
            rootView: DeleteRequestLoadingView(screenState: .success),
            style: .modally(presentationStyle: .fullScreen)
        ) { action in
            if case .makeTabActive = action {
                DismissJourney()
            }
        }
    }
}
