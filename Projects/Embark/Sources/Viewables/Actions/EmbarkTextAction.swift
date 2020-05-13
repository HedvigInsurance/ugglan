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
import hCore
import hCoreUI

typealias EmbarkTextActionData = EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkTextAction

struct EmbarkTextAction {
    let store: EmbarkStore
    let data: EmbarkTextActionData
    let passageName: String?
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
        
        var oldText = ""
        bag += textSignal.onValue { textValue in
            let maskedValue = Masking().maskValue(text: textValue, type: .personalNumber, oldText: oldText)
            textSignal.value = maskedValue
            oldText = maskedValue
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
                if let passageName = self.passageName {
                    self.store.setValue(
                        key: "\(passageName)Result",
                        value: textSignal.value
                    )
                }
                self.store.setValue(
                    key: self.data.textActionData.key,
                    value: textSignal.value
                )
                callback(self.data.textActionData.link.fragments.embarkLinkFragment)
            }
                        
            return bag
        })
    }
}

