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
    let passageName: String?
}

extension EmbarkSelectAction: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Signal<EmbarkLinkFragment>) {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        
        let bag = DisposeBag()
        
        return (view, Signal { callback in
            
            let options = self.data.selectActionData.options
            let numberOfStacks = options.count % 2 == 0 ? options.count / 2 : Int(floor(Double(options.count) / 2) + 1)
            
            for i in 1...numberOfStacks {
                let stack = UIStackView()
                stack.spacing = 10
                stack.distribution = .fillEqually
                view.addArrangedSubview(stack)
                
                let optionsSlice = Array(options[2*i-2..<min(2*i, options.count)])
                bag += optionsSlice.map { option in
                    return stack.addArranged(EmbarkSelectActionOption(data: option)).onValue { result in
                        self.store.setValue(key: result.key, value: result.value)
                        self.store.setValue(key: (self.passageName ?? result.key) + "Result", value: result.textValue)
                        callback(option.link.fragments.embarkLinkFragment)
                    }
                }
                if optionsSlice.count < 2 { stack.addArrangedSubview(UIView()) }
            }
            
            return bag
        })
    }
}
