import Apollo
import Contracts
import Foundation
import hCore
import hCoreUI
import Home
import Market
import Mixpanel
import UIKit

struct CrossFrameworkCoordinator {
    static func setup() {
        Button.trackingHandler = { button in
            if let localizationKey = button.title.value.displayValue.derivedFromL10n?.key {
                Mixpanel.mainInstance().track(event: localizationKey, properties: [
                    "context": "Button",
                ])
            }
        }
        UIControl.trackingHandler = { control in
            if let accessibilityLabel = control.accessibilityLabel {
                if let localizationKey = accessibilityLabel.derivedFromL10n?.key {
                    Mixpanel.mainInstance().track(event: "TAP_\(localizationKey)", properties: [
                        "context": "UIControl",
                    ])
                }
            } else if let accessibilityIdentifier = control.accessibilityIdentifier {
                Mixpanel.mainInstance().track(event: "TAP_\(accessibilityIdentifier)", properties: [
                    "context": "UIControl",
                ])
            }
        }
        ButtonRow.trackingHandler = { buttonRow in
            if let localizationKey = buttonRow.text.value.derivedFromL10n?.key {
                Mixpanel.mainInstance().track(event: "TAP_\(localizationKey)", properties: [
                    "context": "ButtonRow",
                ])
            }
        }
        ChatButton.openChatHandler = { chatButton in
            chatButton.presentingViewController.present(
                FreeTextChat().wrappedInCloseButton(),
                style: .detented(.large)
            )
        }

        Home.openClaimsHandler = { viewController in
            viewController.present(
                HonestyPledge().wrappedInCloseButton(),
                style: .detented(.preferredContentSize),
                options: [.defaults, .allowSwipeDismissAlways, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)]
            )
        }

        Home.openCallMeChatHandler = { viewController in
            viewController.present(
                CallMeChat().wrappedInCloseButton(),
                style: .detented(.large)
            )
        }

        Home.openFreeTextChatHandler = { viewController in
            viewController.present(
                FreeTextChat().wrappedInCloseButton(),
                style: .detented(.large)
            )
        }

        Home.openConnectPaymentHandler = { viewController in
            viewController.present(
                PaymentSetup(setupType: .initial),
                style: .detented(.large)
            )
        }

        Contracts.openFreeTextChatHandler = { viewController in
            viewController.present(
                FreeTextChat().wrappedInCloseButton(),
                style: .detented(.large)
            )
        }

        CrossFramework.presentOnboarding = { viewController in
            viewController.present(
                Onboarding(),
                options: [.defaults, .prefersNavigationBarHidden(false)]
            )
        }

        CrossFramework.presentLogin = { viewController in
            viewController.present(
                BankIDLogin(),
                options: [.defaults, .allowSwipeDismissAlways]
            )
        }

        CrossFramework.onRequestLogout = {
            UIApplication.shared.appDelegate.logout()
        }

        CrossFramework.reinitApolloClient = {
            ApolloClient.initAndRegisterClient()
        }
    }
}
