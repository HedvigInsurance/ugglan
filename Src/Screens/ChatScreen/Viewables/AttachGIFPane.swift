//
//  AttachGIFPane.swift
//  project
//
//  Created by Sam Pettersson on 2019-07-30.
//

import Flow
import Foundation
import UIKit

struct AttachGIFPane {
    let isOpenSignal: ReadSignal<Bool>
}

extension AttachGIFPane: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let view = UIView()
        
        bag += isOpenSignal.atOnce().map { !$0 }.animated(style: SpringAnimationStyle.lightBounce(), animations: { isHidden in
            view.animationSafeIsHidden = isHidden
            view.layoutSuperviewsIfNeeded()
        })
        
        view.backgroundColor = .turquoise
        
        bag += view.didMoveToWindowSignal.onValue { _ in
            view.snp.remakeConstraints({ make in
                make.width.equalToSuperview()
                make.height.equalTo(300)
            })
        }
        
        return (view, bag)
    }
}
