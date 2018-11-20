//
//  AppNavigation.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-07.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import Tempura

enum Screen: String {
    case marketing
    case chat
}

extension ChatViewController: RoutableWithConfiguration {
    var routeIdentifier: RouteElementIdentifier {
        return Screen.chat.rawValue
    }

    var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
        return [
            .show(Screen.chat): .presentModally({ [unowned self] _ in
                let chatViewController = ChatViewController(store: self.store)
                chatViewController.modalPresentationStyle = .overCurrentContext
                return chatViewController
            })
        ]
    }
}

extension MarketingViewController: RoutableWithConfiguration {
    var routeIdentifier: RouteElementIdentifier {
        return Screen.marketing.rawValue
    }

    var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
        return [
            .show(Screen.chat): .push({ [unowned self] _ in
                let chatViewController = ChatViewController(store: self.store)
                return chatViewController
            }),
            .show(Screen.marketing): .presentModally({ [unowned self] _ in
                let marketingViewController = MarketingViewController(store: self.store)
                marketingViewController.modalPresentationStyle = .overCurrentContext
                return marketingViewController
            })
        ]
    }
}
