//
//  PriceBubble.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-06.
//

import Flow
import Foundation
import UIKit

struct PriceBubble {
    let containerScrollView: UIScrollView
    let insuranceSignal = ReadWriteSignal<OfferQuery.Data.Insurance?>(nil)
}

extension PriceBubble: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
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

        let labelText = DynamicString("")
        let subLabelText = DynamicString("kr/mån")

        bag += insuranceSignal.compactMap { $0?.cost?.fragments.costFragment.monthlyNet.amount }.toInt().compactMap { $0 }.map { String($0) }.bindTo(labelText)

        let circle = CircleLabelWithSubLabel(
            labelText: labelText,
            subLabelText: subLabelText,
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
        }())) { bubbleView in

            let innerBag = DisposeBag()

            bubbleView.transform = CGAffineTransform(scaleX: 0, y: 0).concatenating(CGAffineTransform(translationX: 0, y: -30))
            bubbleView.alpha = 0

            innerBag += Signal(after: 0.75)
                .animated(style: SpringAnimationStyle.mediumBounce()) { _ in
                    bubbleView.alpha = 1
                    bubbleView.transform = CGAffineTransform.identity
                    innerBag.dispose()
                }
        }

        return (stackView, bag)
    }
}
