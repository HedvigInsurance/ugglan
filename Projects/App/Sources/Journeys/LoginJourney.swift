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

    fileprivate static var bankIDSweden: some JourneyPresentation {
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
                    }
                }
                .withJourneyDismissButton
                .mapJourneyDismissToCancel
            case .loggedIn:
                loginCompleted
            }
        }
        .withDismissButton
    }

    fileprivate static var simpleSign: some JourneyPresentation {
        Journey(SimpleSignLoginView(), style: .detented(.large)) { id in
            Journey(WebViewLogin(idNumber: id), style: .detented(.large)) { _ in
                loginCompleted
            }
        }
        .withDismissButton
    }

    fileprivate static var otp: some JourneyPresentation {
        OTPAuthJourney.login { next in
            switch next {
            case let .success(accessToken):
                Journey(ApolloClientSaveTokenLoader(accessToken: accessToken)) { _ in
                    loginCompleted
                }
            case .chat:
                AppJourney.freeTextChat().withDismissButton
            }
        }
        .setStyle(.detented(.large)).withDismissButton
    }

    @JourneyBuilder static var login: some JourneyPresentation {
        switch hAnalyticsExperiment.loginMethod {
        case .bankIdSweden:
            bankIDSweden
        case .simpleSign:
            simpleSign
        case .otp:
            otp
        case .disabled:
            ContinueJourney()
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
