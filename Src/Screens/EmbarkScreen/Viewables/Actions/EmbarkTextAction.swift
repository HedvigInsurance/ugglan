//
//  EmbarkTextAction.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-16.
//

import Foundation
import Flow
import Presentation
import UIKit

typealias EmbarkTextActionData = EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkTextAction

struct EmbarkTextAction {
    let store: EmbarkStore
    let data: EmbarkTextActionData
}

extension EmbarkTextAction: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Signal<EmbarkLinkFragment>) {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        let bag = DisposeBag()
                        
        let textView = TextView(placeholder: data.textActionData.placeholder)
        let (textInputView, textSignal) = textView.materialize(events: events)
                
        view.addArrangedSubview(textInputView)
        
        let currentTextSignal: ReadWriteSignal<String> = ReadWriteSignal("")
        
        bag += textSignal.onValue { textValue in
            print("TEXT:", textValue)
            //let diff = 
        }
        
        let button = Button(
            title: data.textActionData.link.fragments.embarkLinkFragment.label,
            type: .standard(backgroundColor: .white, textColor: .black)
        )
        
        bag += view.addArranged(button)
        
        return (view, Signal { callback in
            
            bag += textSignal.onValue({ _ in
                
            })
            
            bag += button.onTapSignal.onValue { _ in
                callback(self.data.textActionData.link.fragments.embarkLinkFragment)
            }
                        
            return bag
        })
    }
}

