//
//  PriceBubble.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-06.
//

import Foundation
import Flow
import UIKit

struct PriceBubble {
    let containerScrollView: UIScrollView
}

extension PriceBubble: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let stackView = UIStackView()
        stackView.layoutMargins = UIEdgeInsets(horizontalInset: 0, verticalInset: 15)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        bag += containerScrollView.contentOffsetSignal.onValue { contentOffset in
            stackView.transform = CGAffineTransform(
                translationX: 0,
                y: (contentOffset.y / 5)
            )
        }
        
        let circle = CircleLabelWithSubLabel(
            labelText: DynamicString("79"),
            subLabelText: DynamicString("kr/mån"),
            appearance: .white
        )
        
        bag += stackView.addArranged(circle.wrappedIn({ () -> UIView in
            let view = UIView()
            
            bag += view.windowSignal.compactMap { $0 }.onValue({ window in
                if window.frame.height < 700 {
                    view.snp.makeConstraints({ make in
                        make.width.height.equalTo(125)
                    })
                } else {
                    view.snp.makeConstraints({ make in
                        make.width.height.equalTo(180)
                    })
                }
            })
            
            return view
        }()))
        
        return (stackView, bag)
    }
}
