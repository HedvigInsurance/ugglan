import Apollo
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct DeleteRequestLoadingView: View {
    @PresentableStore var store: ProfileStore
    @Inject var octopus: hOctopus

    enum ScreenState {
        case sendingMessage(MemberDetails)
        case success
        case error
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
                    .foregroundColor(hTextColor.primaryTranslucent)
                hText(L10n.DeleteAccount.processedDescription, style: .body)
                    .foregroundColor(hTextColor.secondaryTranslucent)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, UIScreen.main.bounds.size.height / 3.5)
            .padding(.horizontal, 32)
        }
        .hFormAttachToBottom {
            hButton.LargeButton(type: .ghost) {
                store.send(.makeTabActive(deeplink: .home))
            } content: {
                hText(L10n.generalCloseButton, style: .body)
            }
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder private var errorState: some View {
        VStack {
            Spacer()
            VStack {
                hCoreUIAssets.circularCross.view
                    .frame(width: 32, height: 32)

                Spacer()
                    .frame(height: 16)

                hText(L10n.HomeTab.errorTitle, style: .body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Spacer()
                    .frame(height: 16)

                hText(L10n.offerSaveStartDateErrorAlertTitle, style: .callout)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            Spacer()

            hButton.LargeButtonOutlined {
                store.send(.makeTabActive(deeplink: .home))
            } content: {
                hText("Back to home", style: .body)
                    .foregroundColor(.primary)
            }
            .padding([.top, .horizontal])
            .padding(.bottom, 40)
        }
    }

    var body: some View {
        switch screenState {
        case let .sendingMessage(memberDetails):
            sendingState
                .onAppear {
                    sendSlackMessage(details: memberDetails)
                }
        case .success:
            successState
        case .error:
            errorState
        }
    }

    private func sendSlackMessage(details: MemberDetails) {
        self.octopus.client
            .perform(mutation: OctopusGraphQL.MemberDeletionRequestMutation())
            .onValue { value in
                if let _ = value.memberDeletionRequest?.message {
                    screenState = .error
                } else {
                    ApolloClient.saveDeleteAccountStatus(for: details.id)
                    screenState = .success
                }
            }
            .onError { graphQLError in
                screenState = .error
            }
    }
}

struct DeleteRequestLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteRequestLoadingView(screenState: .success)
    }
}
