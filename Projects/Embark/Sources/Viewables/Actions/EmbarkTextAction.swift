//
//  EmbarkTextAction.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-16.
//

import Flow
import Foundation
import hCore
import hCoreUI
import Presentation
import UIKit

typealias EmbarkTextActionData = EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkTextAction

struct EmbarkTextAction {
    let state: EmbarkState
    let data: EmbarkTextActionData
    
    var masking: Masking? {
        if let mask = self.data.textActionData.mask,
            let maskType = MaskType(rawValue: mask) {
            return Masking(type: maskType)
        }
        
        return nil
    }
}

extension EmbarkTextAction: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Signal<EmbarkLinkFragment>) {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        let bag = DisposeBag()

        let textView = EmbarkInput(
            placeholder: data.textActionData.placeholder,
            keyboardType: masking?.keyboardType,
            textContentType: masking?.textContentType,
            masking: masking
        )
        let (textInputView, textSignal) = textView.materialize(events: events)

        view.addArrangedSubview(textInputView)

        let button = Button(
            title: data.textActionData.link.fragments.embarkLinkFragment.label,
            type: .standard(backgroundColor: .black, textColor: .white)
        )

        bag += view.addArranged(button)

        return (view, Signal { callback in
            func complete() {
                if let passageName = self.state.passageNameSignal.value {
                   self.state.store.setValue(
                       key: "\(passageName)Result",
                       value: textSignal.value
                   )
               }
               let unmaskedValue = self.masking?.unmaskedValue(text: textSignal.value) ?? textSignal.value
               self.state.store.setValue(
                   key: self.data.textActionData.key,
                   value: unmaskedValue
               )
               
               if let derivedValues = self.masking?.derivedValues(text: textSignal.value) {
                   derivedValues.forEach { (key, value) in
                       self.state.store.setValue(
                           key: "\(self.data.textActionData.key)\(key)",
                           value: value
                       )
                   }
               }
               
               callback(self.data.textActionData.link.fragments.embarkLinkFragment)
            }
            
            bag += textView.shouldReturn.set { _ -> Bool in
                complete()
                return true
            }
            
            bag += button.onTapSignal.onValue { _ in
               complete()
            }

            return bag
        })
    }
}
