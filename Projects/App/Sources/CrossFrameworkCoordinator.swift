import Apollo
import Contracts
import Embark
import Flow
import Foundation
import Home
import Market
import Payment
import UIKit
import hCore
import hCoreUI

struct CrossFrameworkCoordinator {
    static func setup() {
        ChatButton.openChatHandler = { viewController in
            viewController
                .present(
                    AppJourney.freeTextChat().withDismissButton
                )
                .onValue { _ in

                }
        }

        CrossFramework.onRequestLogout = { UIApplication.shared.appDelegate.logout() }
    }
}
