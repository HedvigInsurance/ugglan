//
//  EmbarkSelectAction.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-16.
//

import Foundation
import Flow
import Presentation
import UIKit

typealias EmbarkSelectActionData = EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkSelectAction

struct EmbarkSelectAction {
    let store: EmbarkStore
    let data: EmbarkSelectActionData
}

extension EmbarkSelectAction: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Signal<EmbarkLinkFragment>) {
        let view = UIStackView()
        view.distribution = .fillEqually
        view.spacing = 10
        let bag = DisposeBag()
        
        return (view, Signal { callback in
            bag += self.data.selectActionData.options.map { option in
                view.addArranged(EmbarkSelectActionOption(data: option)).onValue { result in
                    self.store.setValue(key: result.key, value: result.value)
                    callback(option.link.fragments.embarkLinkFragment)
                }
            }
            
            return bag
        })
    }
}
