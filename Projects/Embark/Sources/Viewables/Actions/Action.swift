//
//  Action.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-16.
//

import Foundation
import Flow
import UIKit
import hCore
import hCoreUI

struct Action {
    let state: EmbarkState
}

struct ActionResponse {
    let link: EmbarkLinkFragment
    let data: ActionResponseData
}

struct ActionResponseData {
    let keys: [String]
    let values: [String]
    let textValue: String
}

extension Action: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Signal<EmbarkLinkFragment>) {
        let view = UIStackView()
        view.axis = .vertical
        view.transform = CGAffineTransform(translationX: 0, y: 300)
        
        let bag = DisposeBag()
        
        let backButton = Button(title: "Go back", type: .standardSmall(backgroundColor: .black, textColor: .white))
        bag += backButton.onTapSignal.onValue {
            self.state.goBack()
        }
        
        bag += view.addArranged(backButton.wrappedIn(UIStackView())) { buttonView in
            buttonView.axis = .vertical
            buttonView.alignment = .center
            buttonView.distribution = .equalCentering
            bag += self.state.canGoBackSignal.delay(by: 0.25).atOnce().map {!$0}.bindTo(buttonView, \.isHidden)
        }
        
        let spacing = Spacing(height: 12)
        bag += view.addArranged(spacing)
        
        let actionDataSignal = self.state.currentPassageSignal.map { $0?.action }
        
        bag += actionDataSignal.withLatestFrom(self.state.passageNameSignal).animated(style: SpringAnimationStyle.lightBounce()) { actionData, passageName in
            if let selectAction = actionData?.asEmbarkSelectAction {
                let stackView = UIStackView()
                bag += stackView.addArranged(EmbarkSelectAction(
                    state: self.state,
                    data: selectAction
                )).nil()
                
                let height = stackView.systemLayoutSizeFitting(.zero).height + (view.superview?.safeAreaInsets.bottom ?? 0) + backButton.type.value.height + 12
                view.transform = CGAffineTransform(translationX: 0, y: height)
            } else {
                view.transform = CGAffineTransform(translationX: 0, y: 300)
            }
        }.delay(by: 0.25).animated(style: SpringAnimationStyle.lightBounce()) { _ in
            view.transform = CGAffineTransform.identity
        }
        
        return (view, Signal { callback in
            bag += actionDataSignal.withLatestFrom(self.state.passageNameSignal).delay(by: 0.25).onValueDisposePrevious { actionData, passageName in
                let innerBag = DisposeBag()
                                
                if let selectAction = actionData?.asEmbarkSelectAction {
                    innerBag += view.addArranged(EmbarkSelectAction(
                        state: self.state,
                        data: selectAction
                    )).onValue(callback)
                } else if let textAction = actionData?.asEmbarkTextAction {
                    innerBag += view.addArranged(EmbarkTextAction(
                        state: self.state,
                        data: textAction
                    )).onValue(callback)
                } else if let numberAction = actionData?.asEmbarkNumberAction {
                    innerBag += view.addArranged(EmbarkNumberAction(
                        state: self.state,
                        data: numberAction
                    )).onValue(callback)
                }
                
                return innerBag
            }
            
            return bag
        })
    }
}
