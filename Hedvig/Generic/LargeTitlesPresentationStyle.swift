//
//  LargeTitlesPresentationStyle.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-02.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import Presentation
import UIKit

struct LargeTitlesPresentationStyle {
    static let style = PresentationStyle(name: "largeTitles") {
        (
            viewController,
            presentingViewController,
            _
        ) -> PresentationStyle.Result in

        let (present, dismiss) = PresentationStyle.default.present(
            viewController,
            from: presentingViewController,
            options: .defaults
        )

        if let navigationBar = viewController.navigationController?.navigationBar {
            if #available(iOS 11.0, *) {
                navigationBar.prefersLargeTitles = true
            }
        }

        return (present, dismiss)
    }
}

extension PresentationStyle {
    static let prefersLargeTitles = LargeTitlesPresentationStyle.style
}
