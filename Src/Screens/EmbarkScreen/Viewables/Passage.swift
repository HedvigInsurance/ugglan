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
            dataSignal: dataSignal.map { $0?.messages }
            
        )
        bag += view.addArranged(embarkMessages)
        
        let action = Action(
            store: store,
            dataSignal: dataSignal.map { $0?.action }
        )
        
        return (view, Signal { callback in
            bag += view.addArranged(action).onValue(callback)
            return bag
        })
    }
}
