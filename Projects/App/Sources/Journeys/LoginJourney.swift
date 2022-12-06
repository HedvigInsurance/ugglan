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
                            otp
                        }
                    }
                    .withJourneyDismissButton
                    .mapJourneyDismissToCancel
                case .loggedIn:
                    loginCompleted
                case .emailLogin:
                    otp
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
                    otp
                }
            }
            .withJourneyDismissButton
            .mapJourneyDismissToCancel
        }
    }

    fileprivate static var otp: some JourneyPresentation {
        OTPAuthJourney.login { next in
            switch next {
            case .success:
                loginCompleted
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
        case .bankIdNorway:
            bankIDSweden
        case .nemId:
            bankIDSweden
        case .otp:
            otp
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
