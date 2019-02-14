//
//  FeedbackImage.swift
//  Hedvig
//
//  Created by Gustaf Gunér on 2019-02-14.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Foundation
import UIKit

struct FeedbackLabel {}

extension FeedbackLabel: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        let containerView = UIView()
        
        let backgroundWithLabel = BackgroundWithLabel(
            labelText: DynamicString("Hjälp oss bli\nbättre!"),
            backgroundColor: .purple,
            backgroundImage: Asset.feedbackLabelBackground.image
        )
        
        bag += containerView.add(backgroundWithLabel)
        
        containerView.makeConstraints(wasAdded: events.wasAdded).onValue { make, _ in
            make.width.equalToSuperview()
            make.height.equalTo(200)
        }
        
        return (containerView, bag)
    }
}
