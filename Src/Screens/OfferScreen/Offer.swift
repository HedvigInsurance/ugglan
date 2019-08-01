//
//  Offer.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-07-31.
//

import Flow
import Form
import Presentation
import UIKit

struct Offer {
}

extension Offer: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let (viewController, future) = Chat().materialize()
        return (viewController, future.disposable)
    }
}
