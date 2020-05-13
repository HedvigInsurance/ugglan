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
import hCore
import hCoreUI

typealias EmbarkNumberActionData = EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkNumberAction

struct EmbarkNumberAction {
    let store: EmbarkStore
    let data: EmbarkNumberActionData
    let passageName: String?
}

extension EmbarkNumberAction: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Signal<EmbarkLinkFragment>) {
        let bag = DisposeBag()
        
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        
        let box = UIView()
        box.backgroundColor = .white
        box.layer.cornerRadius = 10
        bag += box.applyShadow({ _ -> UIView.ShadowProperties in
            UIView.ShadowProperties(
                opacity: 0.25,
                offset: CGSize(width: 0, height: 6),
                radius: 8,
                color: .brand(.primaryShadowColor),
                path: nil
            )
        })
        
        let boxStack = UIStackView()
        boxStack.axis = .vertical
        boxStack.edgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        return (view, Signal { callback in
            
            func handleSubmit(textValue: String) {
                let key = self.data.numberActionData.key
                self.store.setValue(key: key, value: textValue)
                if let passageName = self.passageName {
                    self.store.setValue(key: "\(passageName)Result", value: textValue)
                }
                callback(self.data.numberActionData.link.fragments.embarkLinkFragment)
            }
            
            let textField = EmbarkInput(placeholder: self.data.numberActionData.placeholder, allowedCharacters: CharacterSet.decimalDigits)
           textField.keyboardTypeSignal.value = .numberPad
           let (textInputView, textSignal) = textField.materialize(events: events)
           boxStack.addArrangedSubview(textInputView)
            
            bag += textField.shouldReturn.set { value -> Bool in
                handleSubmit(textValue: value)
                return true
            }
           
            if let unit = self.data.numberActionData.unit {
               let unitLabel = MultilineLabel(value: unit, style: .centeredBodyOffBlack)
               bag += boxStack.addArranged(unitLabel)
           }
           
           box.addSubview(boxStack)
           boxStack.snp.makeConstraints { make in
               make.top.bottom.right.left.equalToSuperview()
           }
           
           view.addArrangedSubview(box)
           
           let button = Button(
            title: self.data.numberActionData.link.fragments.embarkLinkFragment.label,
               type: .standard(backgroundColor: .white, textColor: .black)
           )
           
           bag += view.addArranged(button)
            
            bag += button.onTapSignal.withLatestFrom(textSignal.plain()).onValue { _, textValue in
                handleSubmit(textValue: textValue)
            }
                        
            return bag
        })
    }
}

