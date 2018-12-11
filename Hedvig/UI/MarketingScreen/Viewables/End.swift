//
//  End.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-07.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Foundation
import INTUAnimationEngine
import UIKit

struct End {}

extension End: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let view = UIView()
        view.alpha = 0
        view.transform = CGAffineTransform(translationX: 0, y: 250)

        let bag = DisposeBag()

        let emoji = UILabel()
        emoji.text = "👋"
        emoji.font = emoji.font.withSize(50)

        emoji.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.center.equalToSuperview()
        }

        let sayHello = UILabel()
        sayHello.text = "Säg hej till Hedvig!"
        sayHello.font = HedvigFonts.circularStdBook?.withSize(18)
        sayHello.textColor = HedvigColors.white

        sayHello.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.top.equalTo(emoji.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }

        let continueButton = UIButton(title: "Fortsätt", style: .standardWhite)

        continueButton.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.top.equalTo(sayHello.snp.bottom).offset(20)
            make.width.equalTo(120)
            make.centerX.equalToSuperview()
        }

        _ = view.didMoveToWindowSignal.delay(by: 0.1).animated(
            style: SpringAnimationStyle.lightBounce()
        ) { progress in
            view.alpha = INTUInterpolateCGFloat(0, 1, progress)
            let translateY = INTUInterpolateCGFloat(250, 0, progress)
            view.transform = CGAffineTransform(translationX: 0, y: translateY)
        }

        bag += view.makeConstraints(wasAdded: events.wasAdded).onValue({ make, _ in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        })

        view.addSubview(continueButton)
        view.addSubview(sayHello)
        view.addSubview(emoji)

        return (view, bag)
    }
}
