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
    
    @ViewBuilder private func errorState(errorMessage: String) -> some View {
        VStack {
            Spacer()
            
            RetryView(subtitle: errorMessage)
            Spacer()

            hButton.LargeButtonOutlined {
                store.send(.makeTabActive(deeplink: .home))
            } content: {
                hText(L10n.generalCloseButton, style: .body)
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
        case let .error(errorMessage):
            errorState(errorMessage: errorMessage)
        }
    }
    
    private func sendSlackMessage(details: MemberDetails) {
        self.octopus.client
            .perform(mutation: OctopusGraphQL.MemberDeletionRequestMutation())
            .onValue { value in
                if let errorFromGraphQL = value.memberDeletionRequest?.message {
                    screenState = .error(errorMessage: errorFromGraphQL)
                } else {
                    ApolloClient.saveDeleteAccountStatus(for: details.id)
                    screenState = .success
                }
            }
            .onError { graphQLError in
                screenState = .error(errorMessage: L10n.General.errorBody)
            }
    }
}

struct DeleteRequestLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteRequestLoadingView(screenState: .success)
    }
}
