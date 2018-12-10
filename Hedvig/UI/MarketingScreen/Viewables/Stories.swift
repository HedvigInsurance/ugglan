//
//  StoriesCollection.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-30.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Foundation
import SnapKit
import UIKit

struct Stories {
    let marketingStories: ReadSignal<[MarketingStory]>
    let resultCallbacker: Callbacker<MarketingResult>
    let endScreenCallbacker: Callbacker<Void>
}

extension Stories: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let view = UIView()

        let scrollToCallbacker = Callbacker<ScrollTo>()
        let scrollToSignal = scrollToCallbacker.signal()

        let storiesCollection = StoriesCollection(
            scrollToSignal: scrollToSignal,
            marketingStories: marketingStories
        )
        bag += view.add(storiesCollection)

        let storiesIndicator = StoriesIndicator(
            scrollToSignal: scrollToSignal,
            marketingStories: marketingStories,
            endScreenCallbacker: endScreenCallbacker
        ) { direction in
            scrollToCallbacker.callAll(with: direction)
        }
        bag += view.add(storiesIndicator)

        let memberActionButtons = MemberActionButtons(
            resultCallbacker: resultCallbacker
        )
        bag += view.add(memberActionButtons)

        let skipToNextButton = SkipToNextButton {
            scrollToCallbacker.callAll(with: .next)
        }
        bag += view.add(skipToNextButton)

        let skipToPreviousButton = SkipToPreviousButton {
            scrollToCallbacker.callAll(with: .previous)
        }
        bag += view.add(skipToPreviousButton)

        let logo = Logo()
        bag += view.add(logo)

        bag += view.makeConstraints(wasAdded: events.wasAdded).onValue({ make, _ in
            make.width.equalToSuperview()
            make.top.equalToSuperview()
            make.center.equalToSuperview()
            make.height.equalToSuperview()
        })

        return (view, bag)
    }
}
