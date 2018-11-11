//
//  AppNavigation.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-07.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import Tempura

// MARK: - Screens identifiers
enum Screen: String {
    case chat
}

// MARK: - List Screen navigation
extension ChatViewController: RoutableWithConfiguration {
    var routeIdentifier: RouteElementIdentifier {
        return Screen.chat.rawValue
    }
    
    var navigationConfiguration: [NavigationRequest: NavigationInstruction] {
        return [
            .show(Screen.chat): .presentModally({ [unowned self] context in
                let ai = ChatViewController(store: self.store)
                ai.modalPresentationStyle = .overCurrentContext
                return ai
            })]
    }
}
