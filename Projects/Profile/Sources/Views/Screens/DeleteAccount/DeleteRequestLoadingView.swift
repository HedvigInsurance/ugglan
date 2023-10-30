import Apollo
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct DeleteRequestLoadingView: View {
    @PresentableStore var store: ProfileStore
    @Inject var octopus: hOctopus

    enum ScreenState {
        case tryToDelete(with: MemberDetails)
        case success
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
            hButton.LargeButton(type: .ghost) {
                store.send(.makeTabActive(deeplink: .home))
            } content: {
                hText(L10n.generalCloseButton, style: .body)
            }
            .padding(.horizontal, 16)
        }
    }

    private var notAvailableView: some View {
        hSection {
            VStack {
                Spacer()
                RetryView(
                    subtitle:
                        L10n.DeleteAccount.deleteNotAvailable,
                    retryTitle: L10n.openChat
                ) {
                    store.send(.makeTabActive(deeplink: .home))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        store.send(.dismissScreen(openChatAfter: true))
                    }
                }
                Spacer()
                hSection {
                    hButton.LargeButton(type: .ghost) {
                        store.send(.makeTabActive(deeplink: .home))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            store.send(.dismissScreen(openChatAfter: false))
                        }
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

    var body: some View {
        switch screenState {
        case .tryToDelete:
            notAvailableView
        case .success:
            successState
        }
    }
}

struct DeleteRequestLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteRequestLoadingView(screenState: .success)
    }
}
