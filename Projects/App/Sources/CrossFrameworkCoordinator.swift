//
//  CrossFrameworkCoordinator.swift
//  Ugglan
//
//  Created by Sam Pettersson on 2020-08-21.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Contracts
import Foundation
import hCore
import hCoreUI
import Home
import Mixpanel
import UIKit

struct CrossFrameworkCoordinator {
    static func setup() {
        Button.trackingHandler = { button in
            if let localizationKey = button.title.value.derivedFromL10n?.key {
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
                FreeTextChat().withCloseButton,
                style: .modally(
                    presentationStyle: .pageSheet,
                    transitionStyle: nil,
                    capturesStatusBarAppearance: false
                )
            )
        }

        Home.openClaimsHandler = { viewController in
            viewController.present(
                HonestyPledge().withCloseButton,
                style: .detented(.custom { _ -> Double in
                    280
                }),
                options: [.defaults, .allowSwipeDismissAlways, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)]
            )
        }

        Home.openCallMeChatHandler = { viewController in
            viewController.present(
                CallMeChat().withCloseButton,
                style: .modally(
                    presentationStyle: .pageSheet,
                    transitionStyle: nil,
                    capturesStatusBarAppearance: false
                )
            )
        }

        Home.openFreeTextChatHandler = { viewController in
            viewController.present(
                FreeTextChat().withCloseButton,
                style: .modally(
                    presentationStyle: .pageSheet,
                    transitionStyle: nil,
                    capturesStatusBarAppearance: false
                )
            )
        }

        Contracts.openFreeTextChatHandler = { viewController in
            viewController.present(
                FreeTextChat().withCloseButton,
                style: .modally(
                    presentationStyle: .pageSheet,
                    transitionStyle: nil,
                    capturesStatusBarAppearance: false
                )
            )
        }
    }
}
