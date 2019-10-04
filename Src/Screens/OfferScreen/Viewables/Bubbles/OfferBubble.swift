//
//  OfferBubble.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-06.
//

import Flow
import Foundation
import UIKit

struct OfferBubble {
    let content: UIView
    let widthSignal: ReadWriteSignal<CGFloat>
    let heightSignal: ReadWriteSignal<CGFloat>
    let backgroundColorSignal: ReadWriteSignal<UIColor>

    static let shadow = UIView.ShadowProperties(
        opacity: 0.2,
        offset: CGSize(width: 0, height: 2),
        radius: nil,
        color: UIColor.primaryShadowColor,
        path: nil
    )

    init(content: UIView, width: CGFloat, height: CGFloat, backgroundColor: UIColor) {
        self.content = content
        widthSignal = ReadWriteSignal(width)
        heightSignal = ReadWriteSignal(height)
        backgroundColorSignal = ReadWriteSignal(backgroundColor)
    }
}

extension OfferBubble: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let view = UIView()

        bag += view.applyShadow({ _ in
            OfferBubble.shadow
        })

        bag += backgroundColorSignal.atOnce().bindTo(view, \.backgroundColor)

        bag += combineLatest(widthSignal.atOnce(), heightSignal.atOnce()).onValue { width, height in
            view.layer.cornerRadius = width / 2

            view.snp.remakeConstraints({ make in
                make.width.equalTo(width)
                make.height.equalTo(height)
            })
        }

        view.addSubview(content)

        content.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        return (view, bag)
    }
}
