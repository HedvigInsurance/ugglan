//
//  SignalProvider+Loader.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-05-10.
//

import Foundation
import Flow
import UIKit

extension SignalProvider {
    func loader(after: TimeInterval, view: UIView) -> Self {
        let bag = DisposeBag()
        
        let loader = LoadingIndicator(showAfter: after, color: .purple)
        bag += view.add(loader)
        
        bag += self.animated(style: SpringAnimationStyle.lightBounce()) { _ in
            bag.dispose()
            view.isHidden = false
        }
        
        return self
    }
}
