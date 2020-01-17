//
//  Action.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-16.
//

import Foundation
import Flow
import UIKit

struct Action {
    let store: EmbarkStore
    let dataSignal: ReadSignal<EmbarkStoryQuery.Data.EmbarkStory.Passage.Action?>
}

extension Action: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Signal<EmbarkLinkFragment>) {
        let view = UIStackView()
        let bag = DisposeBag()
        
        return (view, Signal { callback in
            bag += self.dataSignal.onValueDisposePrevious { data in
                let innerBag = DisposeBag()
                                
                if let selectAction = data?.asEmbarkSelectAction {
                    innerBag += view.addArranged(EmbarkSelectAction(
                        store: self.store,
                        data: selectAction
                    )).onValue(callback)
                } else if let textAction = data?.asEmbarkTextAction {
                    innerBag += view.addArranged(EmbarkTextAction(
                        store: self.store,
                        data: textAction
                    )).onValue(callback)
                }
                
                return innerBag
            }
            
            return bag
        })
    }
}
