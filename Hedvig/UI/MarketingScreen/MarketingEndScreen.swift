//
//  MarketingEndScreen.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-07.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Presentation
import SnapKit
import UIKit

struct MarketingEnd {}

extension MarketingEnd: Presentable {
    func materialize() -> (UIViewController, Future<MarketingResult>) {
        let viewController = UIViewController()

        let bag = DisposeBag()

        let blurEffect = UIBlurEffect(style: .dark)
        let containerView = UIVisualEffectView(effect: blurEffect)
        viewController.view = containerView

        return (viewController, Future { _ in
            let end = End()

            bag += containerView.contentView.add(end)

            return bag
        })
    }
}
