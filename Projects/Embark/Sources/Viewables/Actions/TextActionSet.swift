//
//  TextActionSet.swift
//  Embark
//
//  Created by sam on 18.5.20.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Foundation
import Flow
import hCore
import hCoreUI
import UIKit

struct TextActionSet {
    let state: EmbarkState
    let data: EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkTextActionSet
}

private typealias TextAction = EmbarkStoryQuery.Data.EmbarkStory.Passage.Action.AsEmbarkTextActionSet.TextActionSetDatum.TextAction

extension TextActionSet: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let view = UIStackView()
        view.axis = .vertical
        let bag = DisposeBag()
                
        let textActions = data.textActionSetData?.textActions.map({ textAction -> (signal: ReadWriteSignal<String>, action: TextAction) in
            let input = EmbarkInput(placeholder: textAction.data?.placeholder ?? "")
            return (signal: view.addArranged(input), action: textAction)
        })
                
        let button = Button(
          title: data.textActionSetData?.link.label ?? "",
          type: .standard(backgroundColor: .white, textColor: .black)
        )
        
        bag += view.addArranged(button)
        
        bag += button.onTapSignal.onValue { _ in
            textActions?.forEach({ (signal, textAction) in
                self.state.store.setValue(key: textAction.data?.key, value: signal.value)
            })
            
            if let passageName = self.state.passageNameSignal.value {
                self.state.store.setValue(key: "\(passageName)Result", value: textActions?.map { $0.signal.value }.joined(separator: " ") ?? "")
            }
            
            if let linkName = self.data.textActionSetData?.link.name {
                self.state.goTo(passageName: linkName)
            }
        }
        
        return (view, bag)
    }
}
