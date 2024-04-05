import Apollo
import Authentication
import Market
import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

@available(iOS 16.0, *)
extension AppJourney {
    fileprivate static var loginCompleted: some JourneyPresentation {
        AppJourney.loggedIn
    }

    fileprivate static var bankIDSweden: some JourneyPresentation {
        HostingJourney(
            AuthenticationStore.self,
            rootView: BankIDLoginQRView {
                let store: UgglanStore = globalPresentableStoreContainer.get()
                await store.sendAsync(.setIsDemoMode(to: true))
                ApolloClient.initAndRegisterClient()
            },
            style: .detented(.large)
        ) { action in
            if case .bankIdQrResultAction(.loggedIn) = action {
                loginCompleted
            } else if case .bankIdQrResultAction(action: .emailLogin) = action {
                otp(style: .detented(.large, modally: false))
            } else if case let .loginFailure(message) = action {
                HostingJourney(
                    AuthenticationStore.self,
                    rootView: GenericErrorView(
                        description: message ?? L10n.authenticationBankidLoginError,
                        buttons: .init(
                            dismissButton: .init(
                                buttonTitle: L10n.generalCloseButton,
                                buttonAction: {
                                    let store: AuthenticationStore = globalPresentableStoreContainer.get()
                                    store.send(.cancel)
                                }
                            )
                        )
                    )
                ) {
                    action in
                    if case .cancel = action {
                        PopJourney()
                    }
                }
            }
        }
        .withJourneyDismissButton
        .mapJourneyDismissToCancel
    }

    fileprivate static func otp(style: PresentationStyle = .detented(.large)) -> some JourneyPresentation {
        OTPAuthJourney.login { next in
            switch next {
            case .success:
                loginCompleted
            }
        }
        .setStyle(style)
        .withDismissButton
    }

    static var login: some JourneyPresentation {
        let marketStore: MarketStore = globalPresentableStoreContainer.get()
        return GroupJourney {
            switch marketStore.state.market {
            case .sweden:
                bankIDSweden
            case .norway, .denmark:
                otp()
            }
        }
        .onDismiss {
            let authenticationStore: AuthenticationStore = globalPresentableStoreContainer.get()
            authenticationStore.send(.cancel)
        }
    }
}
