import Apollo
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct DeleteRequestLoadingView: View {
    @PresentableStore var store: ProfileStore
    @Inject var profileService: ProfileService
    @EnvironmentObject var router: Router

    private var dismissAction: (ProfileNavigationDismissAction) -> Void

    public init(
        screenState: ScreenState,
        dismissAction: @escaping (ProfileNavigationDismissAction) -> Void
    ) {
        self.screenState = screenState
        self.dismissAction = dismissAction
    }

    public enum ScreenState {
        case tryToDelete(with: MemberDetails)
        case success
        case error(errorMessage: String)
    }

    @State var screenState: ScreenState

    @ViewBuilder var sendingState: some View {
        VStack {
            DotsActivityIndicator(.standard).useDarkColor
        }
    }

    @ViewBuilder private var successState: some View {
        hForm {
            VStack(spacing: 0) {
                Image(uiImage: hCoreUIAssets.tick.image)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(hSignalColor.greenElement)
                    .padding(.bottom, 16)
                hText(L10n.DeleteAccount.processedTitle, style: .body)
                    .foregroundColor(hTextColor.primary)
                hText(L10n.DeleteAccount.processedDescription, style: .body)
                    .foregroundColor(hTextColor.secondaryTranslucent)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, UIScreen.main.bounds.size.height / 3.5)
            .padding(.horizontal, 32)
        }
        .hFormAttachToBottom {
            hSection {
                hButton.LargeButton(type: .ghost) {
                    dismissAction(.makeHomeTabActive)
                } content: {
                    hText(L10n.generalCloseButton, style: .body)
                }
            }
            .sectionContainerStyle(.transparent)
        }
    }

    @ViewBuilder private func errorState(errorMessage: String) -> some View {
        GenericErrorView(
            description: errorMessage,
            buttons: .init(
                actionButton: .init(
                    buttonTitle: L10n.generalCloseButton,
                    buttonAction: {
                        dismissAction(.makeHomeTabActive)
                    }
                )
            )
        )
    }

    private var notAvailableView: some View {
        hSection {
            VStack {
                Spacer()
                GenericErrorView(
                    description: L10n.DeleteAccount.deleteNotAvailable,
                    buttons: .init(
                        actionButton: .init(
                            buttonTitle: L10n.openChat,
                            buttonAction: {
                                dismissAction(.makeHomeTabActiveAndOpenChat)
                            }
                        ),
                        dismissButton: nil
                    )
                )
                .hWithoutTitle
                Spacer()
                hSection {
                    hButton.LargeButton(type: .ghost) {
                        dismissAction(.makeHomeTabActiveAndOpenChat)
                    } content: {
                        hText(L10n.generalCancelButton)
                    }
                }
            }
        }
        .sectionContainerStyle(.transparent)
        .background(
            BackgroundView().edgesIgnoringSafeArea(.all)
        )
    }

    public var body: some View {
        switch screenState {
        case let .tryToDelete(memberDetails):
            sendingState
                .onAppear {
                    Task {
                        await sendSlackMessage(details: memberDetails)
                    }
                }
        case .success:
            successState
        case let .error(errorMessage):
            errorState(errorMessage: errorMessage)
        }
    }
    @MainActor
    private func sendSlackMessage(details: MemberDetails) async {
        do {
            try await profileService.postDeleteRequest()
            ApolloClient.saveDeleteAccountStatus(for: details.id)
            screenState = .success
        } catch {
            screenState = .error(errorMessage: L10n.General.errorBody)
        }
    }
}

struct DeleteRequestLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteRequestLoadingView(screenState: .success, dismissAction: { _ in })
    }
}
