//
//  UIStackView+DraggableOverlaySizing.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-06-18.
//

import Foundation
import UIKit
import Flow

extension UIStackView {
    /// Applies a the safeArea of containing window to the stackView layoutMargin
    func applySafeAreaBottomLayoutMargin() -> Disposable {
        let bag = DisposeBag()
        
        if #available(iOS 11, *) {
            bag += didMoveToWindowSignal.onValue { _ in
                let safeAreaBottom = self.window?.safeAreaInsets.bottom ?? 0
                self.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: safeAreaBottom, right: 0)
                self.isLayoutMarginsRelativeArrangement = true
                self.insetsLayoutMarginsFromSafeArea = false
            }
        }
        
        return bag
    }
    
    /// Calculates the preferredContentSize for the stackview and set's it on the viewController
    func applyPreferredContentSize(on viewController: UIViewController) -> Disposable {
        return didLayoutSignal.skip(first: 1).map { _ in
            self.systemLayoutSizeFitting(CGSize.zero)
            }.distinct().bindTo(viewController, \.preferredContentSize)
    }
}
