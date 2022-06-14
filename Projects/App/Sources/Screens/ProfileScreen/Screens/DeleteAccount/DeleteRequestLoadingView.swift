import Apollo
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct DeleteRequestLoadingView: View {
    @PresentableStore var store: UgglanStore

    enum ScreenState {
        case sendingMessage(MemberDetails)
        case success
        case error
    }

    @State var screenState: ScreenState

    @ViewBuilder var sendingState: some View {
        VStack {
            hText("Sending your request...", style: .body)
                .foregroundColor(hLabelColor.primary)
        }
    }

    @ViewBuilder private var successState: some View {
        VStack {
            Spacer()
            VStack {
                hCoreUIAssets.circularCheckmark.view
                    .frame(width: 32, height: 32)

                Spacer()
                    .frame(height: 24)

                hText("We have received your request for account deletion", style: .title2)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Spacer()
                    .frame(height: 16)

                hText(
                    "We will get in touch with you by the email or phone. Your account will be active until then.",
                    style: .callout
                )
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
        let bot = SlackBot()
        bot.postSlackMessage(memberDetails: details)
            .onValue { status in
                self.screenState = status ? .success : .error
                if status {
                    ApolloClient.saveDeleteAccountStatus(for: details.id)
                }
            }
            .onError { _ in
                self.screenState = .error
            }
    }
}

struct DeleteRequestLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteRequestLoadingView(screenState: .success)
    }
}
