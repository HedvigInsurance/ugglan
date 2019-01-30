//
//  MarketingPresentationStyle.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-26.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import Presentation
import UIKit

extension PresentationStyle {
    static let marketing = PresentationStyle(name: "marketing") {
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
            navigationBar.isHidden = true
            navigationBar.barStyle = .black
        }

        return (present, dismiss)
    }
}
