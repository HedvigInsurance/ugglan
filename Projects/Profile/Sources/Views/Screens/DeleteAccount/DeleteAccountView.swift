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
            hForm {
                hSection {
                    RetryView(
                        subtitle:
                            "We can’t delete your account right now. Please contact us in the chat for further assistance.",
                        retryTitle: L10n.openChat
                    ) {
                        let store: ProfileStore = globalPresentableStoreContainer.get()
                        store.send(.dismissScreen)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            store.send(.openChat)
                        }
                    }
                }
            }
            .hFormContentPosition(.center)
            .hDisableScroll
            .sectionContainerStyle(.transparent)
            .hFormAttachToBottom {
                hSection {
                    hButton.LargeButton(type: .ghost) {
                        let store: ProfileStore = globalPresentableStoreContainer.get()
                        store.send(.dismissScreen)
                    } content: {
                        hText(L10n.generalCancelButton)
                    }
                }
            }
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
        let model = DeleteAccountViewModel(
            memberDetails: details,
            claimsStore: claimsStore,
            contractsStore: contractsStore
        )
        return HostingJourney(
            ProfileStore.self,
            rootView: DeleteAccountView(
                viewModel: model
            ),
            style: model.hasActiveClaims || model.hasActiveContracts
                ? .detented(.scrollViewContentSize) : .modally(presentationStyle: .overFullScreen),
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
