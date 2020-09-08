//
//  CircleIcon.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-24.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import hCore
import hCoreUI
import UIKit

struct CircleIcon {
    let iconAsset: ImageAsset
    let iconWidth: CGFloat
    let spacing: CGFloat
    let backgroundColor: UIColor
}

extension CircleIcon: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let view = UIView()
        let circleView = UIView()
        circleView.backgroundColor = backgroundColor

        let bag = DisposeBag()

        bag += circleView.didLayoutSignal.onValue { _ in
            circleView.layer.cornerRadius = circleView.frame.width / 2
        }

        let icon = Icon(frame: .zero, icon: iconAsset.image, iconWidth: iconWidth)
        circleView.addSubview(icon)

        circleView.layer.shadowOpacity = 0.2
        circleView.layer.shadowOffset = CGSize(width: 10, height: 10)
        circleView.layer.shadowRadius = 16
        circleView.layer.shadowColor = UIColor.brand(.primaryShadowColor).cgColor

        view.addSubview(circleView)

        icon.snp.makeConstraints { make in
            make.width.equalTo(self.iconWidth)
            make.height.equalTo(self.iconWidth)
            make.center.equalToSuperview()
        }

        circleView.snp.makeConstraints { make in
            make.width.equalTo(self.iconWidth + self.spacing)
            make.height.equalTo(self.iconWidth + self.spacing)
            make.center.equalToSuperview()
        }

        view.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.height.equalTo(self.iconWidth + self.spacing)
        }

        return (view, bag)
    }
}
