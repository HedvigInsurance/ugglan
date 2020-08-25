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

func setGrabber(on presentationController: UIPresentationController, to value: Bool) {
    let grabberKey = [
        "_", "setWants", "Grabber:",
    ]

    let selector = NSSelectorFromString(grabberKey.joined())

    if presentationController.responds(to: selector) {
        presentationController.perform(selector, with: value)
    }
}

class DetentedTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var detents: [PresentationStyle.Detents]
    var wantsGrabber: Bool

    init(
        detents: [PresentationStyle.Detents],
        wantsGrabber: Bool
    ) {
        self.detents = detents
        self.wantsGrabber = wantsGrabber
        super.init()
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source _: UIViewController) -> UIPresentationController? {
        let key = [
            "_", "U", "I", "Sheet", "Presentation", "Controller",
        ]
        let sheetPresentationController = NSClassFromString(key.joined()) as! UIPresentationController.Type
        let presentationController = sheetPresentationController.init(presentedViewController: presented, presenting: presenting)

        PresentationStyle.Detents.set(detents, on: presentationController)

        setGrabber(on: presentationController, to: wantsGrabber)

        return presentationController
    }
}

extension PresentationOptions {
    // adds a grabber to DetentedModals
    public static let wantsGrabber = PresentationOptions()
}

extension PresentationStyle {
    public enum Detents {
        case medium, large, custom(_ containerViewBlock: (_ containerView: UIView) -> Double)

        static func set(_ detents: [Detents], on presentationController: UIPresentationController) {
            let key = [
                "_", "set", "Detents", ":",
            ]
            let selector = NSSelectorFromString(key.joined())
            presentationController.perform(selector, with: NSArray(array: detents.map { $0.getDetent }))

            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                usingSpringWithDamping: 5,
                initialSpringVelocity: 1,
                options: .allowUserInteraction,
                animations: {
                    presentationController.presentedViewController.view.layoutIfNeeded()
                    presentationController.presentedViewController.view.layoutSuperviewsIfNeeded()
                }, completion: nil
            )
        }

        var rawValue: String {
            switch self {
            case .large:
                return "large"
            case .medium:
                return "medium"
            case .custom:
                return "custom"
            }
        }

        var getDetent: NSObject {
            let key = [
                "_", "U", "I", "S", "h", "e", "e", "t", "D", "e", "t", "e", "n", "t",
            ]

            let DetentsClass = NSClassFromString(key.joined()) as! NSObject.Type

            switch self {
            case .large, .medium:
                return DetentsClass.value(forKey: "_\(rawValue)Detent") as! NSObject
            case let .custom(containerViewBlock):
                typealias ContainerViewBlockMethod = @convention(c) (
                    NSObject.Type,
                    Selector,
                    @escaping (_ containerView: UIView) -> Double
                ) -> NSObject
                let customKey = [
                    "_detent",
                    "WithContainerViewBlock",
                    ":",
                ]
                let selector = NSSelectorFromString(customKey.joined())
                let method = DetentsClass.method(for: selector)
                let castedMethod = unsafeBitCast(method, to: ContainerViewBlockMethod.self)

                return castedMethod(DetentsClass, selector, containerViewBlock)
            }
        }
    }

    public static func detented(_ detents: Detents..., modally: Bool = true) -> PresentationStyle {
        PresentationStyle(name: "detented") { viewController, from, options in
            if #available(iOS 13, *) {
                if modally {
                    let vc = viewController.embededInNavigationController(options)

                    let delegate = DetentedTransitioningDelegate(
                        detents: detents,
                        wantsGrabber: options.contains(.wantsGrabber)
                    )
                    vc.transitioningDelegate = delegate
                    vc.modalPresentationStyle = .custom

                    return from.modallyPresentQueued(vc, options: options) {
                        modalPresentationDismissalSetup(for: vc, options: options)
                    }
                } else {
                    if let presentationController = from.navigationController?.presentationController {
                        Self.Detents.set(detents, on: presentationController)
                        setGrabber(on: presentationController, to: options.contains(.wantsGrabber))
                    }

                    return PresentationStyle.default.present(viewController, from: from, options: options)
                }
            } else {
                if modally {
                    return PresentationStyle.modal.present(viewController, from: from, options: options)
                }

                return PresentationStyle.default.present(viewController, from: from, options: options)
            }
        }
    }
}
