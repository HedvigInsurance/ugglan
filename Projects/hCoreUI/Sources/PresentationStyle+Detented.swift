//
//  PresentationStyle+Detented.swift
//  hCore
//
//  Created by sam on 24.8.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Form
import Foundation
import Presentation
import UIKit

class TransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var detents: [PresentationStyle.Detents]

    init(detents: [PresentationStyle.Detents]) {
        self.detents = detents
        super.init()
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source _: UIViewController) -> UIPresentationController? {
        let key = [
            "_", "U", "I", "Sheet", "Presentation", "Controller",
        ]
        let sheetPresentationController = NSClassFromString(key.joined()) as! UIPresentationController.Type
        let presentationController = sheetPresentationController.init(presentedViewController: presented, presenting: presenting)

        PresentationStyle.Detents.set(detents, on: presentationController)

        return presentationController
    }
}

extension PresentationStyle {
    public enum Detents: String {
        case medium, large

        static func set(_ detents: [Detents], on presentationController: UIPresentationController) {
            let key = [
                "_", "set", "Detents", ":",
            ]
            let selector = NSSelectorFromString(key.joined())
            presentationController.perform(selector, with: NSArray(array: detents.map { $0.getDetent }))

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 5, initialSpringVelocity: 1, options: .allowUserInteraction) {
                presentationController.presentedViewController.view.layoutIfNeeded()
                presentationController.presentedViewController.view.layoutSuperviewsIfNeeded()
            }
        }

        var getDetent: NSObject {
            let key = [
                "_", "U", "I", "S", "h", "e", "e", "t", "D", "e", "t", "e", "n", "t",
            ]
            let detents = NSClassFromString(key.joined()) as! NSObject.Type

            return detents.value(forKey: "_\(rawValue)Detent") as! NSObject
        }
    }

    public static func detented(_ detents: Detents..., modally: Bool = true) -> PresentationStyle {
        PresentationStyle(name: "detented") { viewController, from, options in
            if modally {
                let vc = viewController.embededInNavigationController(options)

                let delegate = TransitioningDelegate(detents: detents)
                vc.transitioningDelegate = delegate
                vc.modalPresentationStyle = .custom

                return from.modallyPresentQueued(vc, options: options) {
                    modalPresentationDismissalSetup(for: vc, options: options)
                }
            } else {
                if let presentationController = from.navigationController?.presentationController {
                    Self.Detents.set(detents, on: presentationController)
                }

                return PresentationStyle.default.present(viewController, from: from, options: options)
            }
        }
    }
}
