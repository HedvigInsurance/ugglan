//
//  PresentationStyle+Hero.swift
//  Home
//
//  Created by sam on 24.8.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import Presentation

extension PresentationStyle {
    static var hero: PresentationStyle {
        PresentationStyle(name: "hero") { viewController, from, options in
            let vc = viewController.embededInNavigationController(options)

            vc.hero.isEnabled = true
            vc.modalPresentationStyle = .pageSheet
            vc.transitioningDelegate = nil

            return from.modallyPresentQueued(vc, options: options) {
                modalPresentationDismissalSetup(for: vc, options: options)
            }
        }
    }
}
