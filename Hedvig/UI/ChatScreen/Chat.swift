//
//  Chat.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-06.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Presentation
import UIKit

struct Chat {}

extension Chat: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()

        let view = UIView()
        view.backgroundColor = HedvigColors.white

        viewController.view = view

        return (viewController, bag)
    }
}
