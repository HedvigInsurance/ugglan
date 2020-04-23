//
//  Passage.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-16.
//

import Foundation
import Flow
import UIKit

struct Passage {
    let store: EmbarkStore
    let dataSignal: ReadWriteSignal<EmbarkStoryQuery.Data.EmbarkStory.Passage?>
    let goBackSignal: ReadWriteSignal<Void>
    let canGoBackSignal: ReadSignal<Bool>
}

extension Passage: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Signal<EmbarkLinkFragment>) {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .equalSpacing
        view.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        view.isLayoutMarginsRelativeArrangement = true
        let bag = DisposeBag()
        
        let embarkMessages = EmbarkMessages(
            store: store,
            dataSignal: dataSignal.map { $0?.messages },
            responseSignal: dataSignal.map { $0?.response.fragments.responseFragment }
        )
        bag += view.addArranged(embarkMessages)
        
        let action = Action(
            store: store,
            dataSignal: dataSignal.map { $0?.action },
            passageName: dataSignal.map { $0?.name },
            goBackSignal: goBackSignal,
            canGoBackSignal: canGoBackSignal
        )
        
        bag += NotificationCenter.default
        .signal(forName: UIResponder.keyboardWillChangeFrameNotification)
        .compactMap { notification in notification.keyboardInfo }
        .animated(mapStyle: { (keyboardInfo) -> AnimationStyle in
            AnimationStyle(options: keyboardInfo.animationCurve, duration: keyboardInfo.animationDuration, delay: 0)
        }, animations: { keyboardInfo in
            view.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: keyboardInfo.height, right: 20)
            view.layoutIfNeeded()
        })
        
        bag += NotificationCenter.default
            .signal(forName: UIResponder.keyboardWillHideNotification)
            .compactMap { notification in notification.keyboardInfo }
            .animated(mapStyle: { (keyboardInfo) -> AnimationStyle in
                AnimationStyle(options: keyboardInfo.animationCurve, duration: keyboardInfo.animationDuration, delay: 0)
        }, animations: { _ in
            view.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            view.layoutIfNeeded()
        })
        
        
        return (view, Signal { callback in
            bag += view.addArranged(action).onValue(callback)
            
            return bag
        })
    }
}
