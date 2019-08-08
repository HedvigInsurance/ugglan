//
//  OfferBubbles.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-06.
//

import Foundation
import Flow
import UIKit

struct OfferBubbles {
    
}

extension OfferBubbles: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let view = UIView()
        
        let width: CGFloat = 300
        
        bag += view.didMoveToWindowSignal.onValue { _ in
            view.snp.remakeConstraints { make in
                make.height.equalTo(width)
                make.width.equalTo(350)
                make.centerX.equalToSuperview()
            }
        }
        
        bag += view.add(DeductibleBubble()) { bubbleView in
            bubbleView.snp.makeConstraints { make in
                make.top.equalTo(190)
                make.left.equalTo(width * 0.23)
            }
        }
        
        bag += view.add(PersonsInHouseholdBubble()) { bubbleView in
            bubbleView.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.left.equalTo(width * 0.2)
            }
        }
        
        return (view, bag)
    }
}
