//
//  EmbarkNumberAction.swift
//  test
//
//  Created by Axel Backlund on 2020-01-30.
//

import Foundation
import Flow
import Presentation
import UIKit

typealias EmbarkNumberActionData = EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkNumberAction

struct EmbarkNumberAction {
    let store: EmbarkStore
    let data: EmbarkNumberActionData
}

extension EmbarkNumberAction: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Signal<EmbarkLinkFragment>) {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        let bag = DisposeBag()
                        
        let textView = TextView(placeholder: data.numberActionData.placeholder)
        let (textInputView, textSignal) = textView.materialize(events: events)
                
        view.addArrangedSubview(textInputView)
        
        let button = Button(
            title: data.numberActionData.link.fragments.embarkLinkFragment.label,
            type: .standard(backgroundColor: .white, textColor: .black)
        )
        
        bag += view.addArranged(button)
        
        return (view, Signal { callback in
            
            bag += textSignal.onValue({ _ in
                
            })
            
            bag += button.onTapSignal.onValue { _ in
                callback(self.data.numberActionData.link.fragments.embarkLinkFragment)
            }
                        
            return bag
        })
    }
}

