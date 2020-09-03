//
//  UIScrollView+EntryAnimation.swift
//  Home
//
//  Created by sam on 27.8.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import hCore
import hCoreUI
import UIKit

extension UIScrollView {
    func performEntryAnimation<Value>(
        contentView: UIView,
        onLoad: Future<Value>,
        onError: @escaping (_ error: Error) -> Void
    ) -> Disposable {
        contentView.alpha = 0
        contentView.transform = CGAffineTransform(translationX: 0, y: 25).concatenating(CGAffineTransform(scaleX: 0.95, y: 0.95))

        let bag = DisposeBag()

        let loadingIndicatorBag = bag.innerBag()

        onLoad.onError { error in
            onError(error)
        }

        let loadingIndicator = LoadingIndicator(showAfter: 0)
        loadingIndicatorBag += add(loadingIndicator) { loadingIndicatorView in
            loadingIndicatorView.snp.makeConstraints { make in
                make.centerY.equalTo(self.frameLayoutGuide.snp.centerY)
            }

            bag += onLoad.valueSignal.animated(style: .lightBounce(duration: 0.5)) { _ in
                loadingIndicatorView.alpha = 0
                loadingIndicatorView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }.onValue { _ in
                loadingIndicatorBag.dispose()
            }
        }

        bag += onLoad.valueSignal.animated(style: .lightBounce(duration: 1)) { _ in
            contentView.transform = .identity
            contentView.alpha = 1
        }

        return bag
    }
}
