import Apollo
import Contracts
import Embark
import Flow
import Foundation
import Home
import Market
import Mixpanel
import Payment
import UIKit
import hCore
import hCoreUI

struct CrossFrameworkCoordinator {
    static func setup() {
        EmbarkTrackingEvent.trackingHandler = { event in let properties = event.properties as? Properties
            Mixpanel.mainInstance().track(event: event.title, properties: properties)
        }

        Button.trackingHandler = { button in
            if let localizationKey = button.title.value.displayValue.derivedFromL10n?.key {
                Mixpanel.mainInstance().track(event: localizationKey, properties: ["context": "Button"])
            }
        }

        UIControl.trackingHandler = { control in
            if let accessibilityLabel = control.accessibilityLabel {
                if let localizationKey = accessibilityLabel.derivedFromL10n?.key {
                    Mixpanel.mainInstance()
                        .track(
                            event: "TAP_\(localizationKey)",
                            properties: ["context": "UIControl"]
                        )
                }
            } else if let accessibilityIdentifier = control.accessibilityIdentifier {
                Mixpanel.mainInstance()
                    .track(
                        event: "TAP_\(accessibilityIdentifier)",
                        properties: ["context": "UIControl"]
                    )
            }
        }
        ButtonRow.trackingHandler = { buttonRow in
            if let localizationKey = buttonRow.text.value.derivedFromL10n?.key {
                Mixpanel.mainInstance()
                    .track(event: "TAP_\(localizationKey)", properties: ["context": "ButtonRow"])
            }
        }
        ChatButton.openChatHandler = { chatButton in
            chatButton.presentingViewController
                .present(
                    AppJourney.freeTextChat().withDismissButton
                )
                .onValue { _ in

                }
        }
        Contracts.openFreeTextChatHandler = { viewController in
            viewController.present(AppJourney.freeTextChat().withDismissButton)
                .onValue { _ in

                }
        }

        CrossFramework.onRequestLogout = { UIApplication.shared.appDelegate.logout() }
    }
}
