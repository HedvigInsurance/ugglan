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
                color: UIColor.primaryShadowColor,
                path: nil
            )
        })
        
        let boxStack = UIStackView()
        boxStack.axis = .vertical
        boxStack.edgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        boxStack.spacing = 10
                        
        let textView = TextView(placeholder: data.numberActionData.placeholder)
        let (textInputView, textSignal) = textView.materialize(events: events)
        boxStack.addArrangedSubview(textInputView)
        
        let unitLabel = MultilineLabel(value: data.numberActionData.unit ?? "", style: .bodyOffBlack)
        bag += boxStack.addArranged(unitLabel)
        
        box.addSubview(boxStack)
        boxStack.snp.makeConstraints { make in
            make.top.bottom.right.left.equalToSuperview()
        }
        
        view.addArrangedSubview(box)
        
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

