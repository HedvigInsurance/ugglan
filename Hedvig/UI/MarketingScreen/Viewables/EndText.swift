//
//  EndText.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-07.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import UIKit

struct EndText {}

extension EndText: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let view = UIView()

        let bag = DisposeBag()

        let emoji = UILabel()
        emoji.text = "👋"
        emoji.font = emoji.font.withSize(50)
        emoji.alpha = 0
        emoji.transform = CGAffineTransform(translationX: 0, y: 250)

        emoji.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.top.equalToSuperview()
        }

        let sayHello = UILabel()
        sayHello.text = "Säg hej till Hedvig!"
        sayHello.alpha = 0
        sayHello.font = HedvigFonts.circularStdBook
        sayHello.transform = CGAffineTransform(translationX: 0, y: 250)

        _ = view.didMoveToWindowSignal.delay(by: 0.5).animated(
            style: AnimationStyle.easeOut(duration: 10)
        ) {
            emoji.alpha = 1
            emoji.transform = CGAffineTransform.identity
        }

        bag += view.makeConstraints(wasAdded: events.wasAdded).onValue({ make, _ in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        })

        view.addSubview(emoji)

        return (view, bag)
    }
}
