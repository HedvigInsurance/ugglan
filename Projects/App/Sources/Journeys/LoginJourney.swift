import Apollo
import Authentication
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hAnalytics

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

    static var login: some JourneyPresentation {
        MarketGroupJourney { market in
            switch market {
            case .se:
                bankIDSweden
            case .no, .dk:
                simpleSign
            case .fr:
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
