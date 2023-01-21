import Apollo
import Authentication
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hAnalytics
import hCore
import hCoreUI

extension AppJourney {
    fileprivate static var loginCompleted: some JourneyPresentation {
        AppJourney.loggedIn.onPresent {
            hAnalyticsEvent.loggedIn().send()
        }
    }

    @JourneyBuilder
    fileprivate static var bankIDSweden: some JourneyPresentation {
        let bankIdAppTestUrl = URL(
            string:
                "bankid:///"
        )!

        if UIApplication.shared.canOpenURL(bankIdAppTestUrl) {
            Journey(
                BankIDLoginSweden(),
                style: .detented(.medium, .large)
            ) { result in
                switch result {
                case .qrCode:
                    Journey(BankIDLoginQR()) { result in
                        switch result {
                        case .loggedIn:
                            loginCompleted
                        case .emailLogin:
                            otp(style: .detented(.large, modally: false))
                        }
                    }
                    .withJourneyDismissButton
                    .mapJourneyDismissToCancel
                case .loggedIn:
                    loginCompleted
                case .emailLogin:
                    otp(style: .detented(.large, modally: false))
                case .close:
                    DismissJourney()
                }
            }
            .withDismissButton
        } else {
            Journey(
                BankIDLoginQR(),
                style: .detented(.medium, .large)
            ) { result in
                switch result {
                case .loggedIn:
                    loginCompleted
                case .emailLogin:
                    otp(style: .detented(.large, modally: false))
                }
            }
            .withJourneyDismissButton
            .mapJourneyDismissToCancel
        }
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

    @JourneyBuilder static var login: some JourneyPresentation {
        GroupJourney {
            switch hAnalyticsExperiment.loginMethod {
            case .bankIdSweden:
                bankIDSweden
            case .bankIdNorway, .nemId:
                ZignsecAuthJourney.login {
                    loginCompleted
                }
            case .otp:
                otp()
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
