//
//  License.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-16.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import AcknowList
import Flow
import Foundation
import Presentation
import UIKit

struct License {
    let acknowledgement: Acknow
}

extension License: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.title = acknowledgement.title

        let scrollView = UIScrollView()
        scrollView.backgroundColor = .offWhite
        scrollView.alwaysBounceVertical = true

        let textLabel = UILabel(
            value: acknowledgement.text,
            style: .body
        )
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byWordWrapping

        bag += textLabel.didLayoutSignal.onValue {
            textLabel.preferredMaxLayoutWidth = textLabel.frame.size.width
            scrollView.contentSize = CGSize(
                width: textLabel.intrinsicContentSize.width,
                height: textLabel.intrinsicContentSize.height + 20
            )
        }

        scrollView.addSubview(textLabel)

        textLabel.snp.makeConstraints({ make in
            make.width.equalToSuperview().inset(10)
            make.top.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
        })

        viewController.view = scrollView

        return (viewController, bag)
    }
}
