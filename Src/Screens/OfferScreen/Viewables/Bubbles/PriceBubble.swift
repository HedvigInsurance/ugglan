//
//  PriceBubble.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-06.
//

import Flow
import Foundation
import UIKit
import Ease
import Form

struct PriceBubble {
    let containerScrollView: UIScrollView
    let insuranceSignal = ReadWriteSignal<OfferQuery.Data.Insurance?>(nil)
}

extension PriceBubble: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let bubbleView = UIView()
        bubbleView.backgroundColor = .white
        
        bag += bubbleView.windowSignal.compactMap { $0 }.onValue({ window in
            if window.frame.height < 700 {
                bubbleView.snp.makeConstraints({ make in
                    make.width.height.equalTo(125)
                })
            } else {
                bubbleView.snp.makeConstraints({ make in
                    make.width.height.equalTo(180)
                })
            }
        })
        
        let stackView = UIStackView()
        stackView.layoutMargins = UIEdgeInsets(horizontalInset: 0, verticalInset: 15)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .vertical
        
        bubbleView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.trailing.leading.top.bottom.equalToSuperview()
        }

        bag += containerScrollView.contentOffsetSignal.onValue { contentOffset in
            stackView.transform = CGAffineTransform(
                translationX: 0,
                y: (contentOffset.y / 5)
            )
        }
        
        let price = MultilineLabel(value: "", style: .rowTitle)

        let ease: Ease<CGFloat> = Ease(0, minimumStep: 1)

        bag += insuranceSignal.compactMap { $0?.cost?.fragments.costFragment.monthlyNet.amount }.toInt().compactMap { $0 }.buffer().onValue({ values in
            guard let value = values.last else { return }
            
            if values.count == 1 {
                ease.value = CGFloat(value)
            }
            
            ease.targetValue = CGFloat(value)
        })
                
        bag += ease.addSpring(tension: 200, damping: 100, mass: 2) { number in
            price.styledTextSignal.value = StyledText(text: String(Int(number)), style: .rowTitle)
        }
        
        bag += stackView.addArranged(price)
        
        bag += stackView.addArranged(MultilineLabel(value: "kr/mån", style: .rowSubtitle))

       let innerBag = DisposeBag()

       bubbleView.transform = CGAffineTransform(scaleX: 0, y: 0).concatenating(CGAffineTransform(translationX: 0, y: -30))
       bubbleView.alpha = 0

       innerBag += Signal(after: 0.75)
           .animated(style: SpringAnimationStyle.mediumBounce()) { _ in
               bubbleView.alpha = 1
               bubbleView.transform = CGAffineTransform.identity
               innerBag.dispose()
           }

        return (bubbleView, bag)
    }
}
