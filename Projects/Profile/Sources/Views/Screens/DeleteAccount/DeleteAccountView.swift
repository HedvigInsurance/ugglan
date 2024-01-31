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
        hForm {
            hSection {
                MarkdownView(
                    text: L10n.DeleteAccount.deleteAccountInfo,
                    fontStyle: .standard
                ) { url in
                    let store: ProfileStore = globalPresentableStoreContainer.get()
                    store.send(.goToURL(url: url))
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: 8) {
                    hButton.LargeButton(type: .alert) { [weak viewModel] in
                        viewModel?.deleteAccount()
                    } content: {
                        hText(L10n.profileDeleteAccountConfirmDeleteion)
                    }
                    .disabled(viewModel.hasActiveClaims || viewModel.hasActiveContracts)
                    hButton.LargeButton(type: .ghost) {
                        let store: ProfileStore = globalPresentableStoreContainer.get()
                        store.send(.dismissScreen(openChatAfter: false))
                    } content: {
                        hText(L10n.generalCancelButton)
                    }
                }
                .padding(.vertical, 16)
            }
            .sectionContainerStyle(.transparent)
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
        let style: PresentationStyle = .modally(presentationStyle: .fullScreen)
        return HostingJourney(
            ProfileStore.self,
            rootView: DeleteAccountView(
                viewModel: model
            ),
            style: style,
            options: [.blurredBackground, .largeNavigationBar]
        ) { action in
            if case let .sendAccountDeleteRequest(memberDetails) = action {
                sendAccountDeleteRequestJourney(details: memberDetails)
            } else if case let .dismissScreen(openChatAfter) = action {
                PopJourney()
                    .onPresent {
                        if openChatAfter {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                let store: ProfileStore = globalPresentableStoreContainer.get()
                                store.send(.openChat)
                            }
                        }
                    }
            }
        }
        .configureTitle(L10n.DeleteAccount.confirmButton)
        .withDismissButton
    }

    static func sendAccountDeleteRequestJourney(details: MemberDetails) -> some JourneyPresentation {
        HostingJourney(
            ProfileStore.self,
            rootView: DeleteRequestLoadingView(screenState: .tryToDelete(with: details))  //,
        ) { action in
            if case .makeTabActive = action {
                DismissJourney()
            }
        }
        .hidesBackButton
    }

    static var deleteRequestAlreadyPlacedJourney: some JourneyPresentation {
        HostingJourney(
            ProfileStore.self,
            rootView: DeleteRequestLoadingView(screenState: .success),
            style: .modally(presentationStyle: .fullScreen)
        ) { action in
            if case .makeTabActive = action {
                PopJourney()
            }
        }
    }
}
