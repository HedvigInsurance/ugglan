//
//  FormScrollView.swift
//  hCoreUI
//
//  Created by Sam Pettersson on 2020-08-10.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import UIKit

public final class FormScrollView: UIScrollView, GradientScroller {
    let bag = DisposeBag()
    public var appliesGradient: Bool = true

    public override init(frame: CGRect) {
        super.init(frame: frame)

        if appliesGradient {
            addGradient(into: bag)
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()

        // fix large titles being collapsed on load
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.navigationController?.navigationBar.sizeToFit()

            if (self?.contentOffset.y ?? 0) < 0 {
                let contentInsetTop = self?.adjustedContentInset.top ?? 0
                self?.setContentOffset(CGPoint(x: 0, y: -contentInsetTop), animated: true)
            }
        }
    }
}
