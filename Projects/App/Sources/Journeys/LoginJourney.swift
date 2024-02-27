import Apollo
import Authentication
import Flow
import Foundation
import Market
import Presentation
import UIKit
import hCore
import hCoreUI

public enum AlternativeLoginMethods {
    case email

    public var value: String {
        switch self {
        case .email:
            return "email"
        }
    }

    public var displayName: String {
        switch self {
        case .email:
            return L10n.emailRowTitle
        }
    }
}

extension AppJourney {
    fileprivate static var loginCompleted: some JourneyPresentation {
        AppJourney.loggedIn
    }

    @JourneyBuilder
    fileprivate static var bankIDSweden: some JourneyPresentation {
        HostingJourney(
            AuthenticationStore.self,
            rootView: BankIDLoginQR(),
            style: .detented(.large)
        ) { action in
            if case .bankIdQrResultAction(.loggedIn) = action {
                loginCompleted
            } else if case .bankIdQrResultAction(action: .emailLogin) = action {
                otpEmail(style: .detented(.large, modally: false))
            } else if case .bankIdQrResultAction(action: .close) = action {
                DismissJourney()
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

    fileprivate static func otpEmail(style: PresentationStyle = .detented(.large)) -> some JourneyPresentation {
        OTPAuthJourney.loginEmail { next in
            switch next {
            case .success:
                loginCompleted
            }
        }
        .setStyle(style)
        .withDismissButton
    }

    fileprivate static func otpSSN(style: PresentationStyle = .detented(.large)) -> some JourneyPresentation {
        OTPAuthJourney.loginSSN { next in
            switch next {
            case .success:
                loginCompleted
            }
        }
        .setStyle(style)
        .withDismissButton
    }

    @JourneyBuilder static var login: some JourneyPresentation {
        let marketStore: MarketStore = globalPresentableStoreContainer.get()
        GroupJourney {
            switch marketStore.state.market {
            case .sweden:
                bankIDSweden
            case .norway, .denmark:
                otpSSN()
            }
        }
        .onDismiss {
            let authenticationStore: AuthenticationStore = globalPresentableStoreContainer.get()
            authenticationStore.send(.cancel)
        }
    }
}

extension MenuChildAction {
    static var login: MenuChildAction {
        MenuChildAction(identifier: "login")
    }
}

extension MenuChild {
    public static var login: MenuChild {
        MenuChild(
            title: L10n.settingsLoginRow,
            style: .default,
            image: hCoreUIAssets.memberCard.image,
            action: .login
        )
    }
}
