import Apollo
import Authentication
import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

extension AppJourney {
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
                        AppJourney.loggedIn
                    }
                }
                .withJourneyDismissButton
                .mapJourneyDismissToCancel
            case .loggedIn:
                AppJourney.loggedIn
            }
        }
        .withDismissButton
    }

    fileprivate static var simpleSign: some JourneyPresentation {
        Journey(SimpleSignLoginView(), style: .detented(.medium)) { id in
            Journey(WebViewLogin(idNumber: id), style: .detented(.large)) { _ in
                AppJourney.loggedIn
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
                OTPAuthJourney.login { accessToken in
                    Journey(ApolloClientSaveTokenLoader(accessToken: accessToken)) { _ in
                        AppJourney.loggedIn
                    }
                }.style(.detented(.large)).withDismissButton
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
