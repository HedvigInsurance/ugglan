//
//  FeedbackHeader.swift
//  Hedvig
//
//  Created by Gustaf Gunér on 2019-02-14.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Foundation
import UIKit

struct FeedbackHeader {
    let height: Float = 200
}

extension FeedbackHeader: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let containerView = UIView()

        let backgroundWithLabel = BackgroundWithLabel(
            labelText: DynamicString(String(.FEEDBACK_SCREEN_LABEL)),
            backgroundColor: .purple,
            backgroundImage: Asset.feedbackLabelBackground.image
        )

        bag += containerView.add(backgroundWithLabel)

        containerView.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.width.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(self.height)
        }

        return (containerView, bag)
    }
}
