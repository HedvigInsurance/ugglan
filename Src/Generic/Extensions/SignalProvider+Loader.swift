//
//  SignalProvider+Loader.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-05-10.
//

import Flow
import Foundation
import UIKit

extension SignalProvider {
    func loader(after: TimeInterval, view: UIView) -> Self {
        let bag = DisposeBag()

        let loader = LoadingIndicator(showAfter: after, color: .purple)
        bag += view.add(loader)

        bag += animated(style: SpringAnimationStyle.lightBounce()) { _ in
            bag.dispose()
            view.isHidden = false
        }

        return self
    }
}
