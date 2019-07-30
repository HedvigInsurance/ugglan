//
//  AttachFilePane.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-07-30.
//

import Foundation
import Flow
import UIKit

struct AttachFilePane {
    let isOpenSignal: ReadSignal<Bool>
}

extension AttachFilePane: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let view = UIView()
        
        bag += isOpenSignal.atOnce().map { !$0 }.animated(style: SpringAnimationStyle.lightBounce(), animations: { isHidden in
            view.isHidden = isHidden
            view.layoutSuperviewsIfNeeded()
        })
        
        view.backgroundColor = .purple
        
        bag += view.didMoveToWindowSignal.onValue { _ in
            view.snp.remakeConstraints({ make in
                make.width.equalToSuperview()
                make.height.equalTo(300)
            })
        }
        
        return (view, bag)
    }
}
