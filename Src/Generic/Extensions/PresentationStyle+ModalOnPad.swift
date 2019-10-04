//
//  PresentationStyle+ModalOnPad.swift
//  test
//
//  Created by Sam Pettersson on 2019-09-24.
//

import Foundation
import Presentation

extension PresentationStyle {
    static let defaultOrModal = PresentationStyle(name: "DefaultOrModal") { (viewController, from, options) -> PresentationStyle.Result in
        if from.traitCollection.isPad {
            return PresentationStyle.modally(
                presentationStyle: .formSheet,
                transitionStyle: nil,
                capturesStatusBarAppearance: true
            ).present(viewController, from: from, options: options)
        }

        return PresentationStyle.default.present(viewController, from: from, options: options)
    }
}
