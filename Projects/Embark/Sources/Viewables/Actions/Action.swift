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
    let store: EmbarkStore
    let dataSignal: ReadSignal<EmbarkStoryQuery.Data.EmbarkStory.Passage.Action?>
    let passageName: ReadSignal<String?>
    let goBackSignal: ReadWriteSignal<Bool>
    let canGoBackSignal: ReadSignal<Bool>
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
        bag += backButton.onTapSignal.map { true }.bindTo(goBackSignal)
        bag += view.addArranged(backButton.wrappedIn(UIStackView())) { buttonView in
            buttonView.axis = .vertical
            buttonView.alignment = .center
            buttonView.distribution = .equalCentering
            bag += canGoBackSignal.delay(by: 0.25).atOnce().map {!$0}.bindTo(buttonView, \.isHidden)
        }
        
        let spacing = Spacing(height: 12)
        bag += view.addArranged(spacing)
        
        bag += self.dataSignal.withLatestFrom(self.passageName).animated(style: SpringAnimationStyle.lightBounce()) { data, passageName in
            if let selectAction = data?.asEmbarkSelectAction {
                let stackView = UIStackView()
                bag += stackView.addArranged(EmbarkSelectAction(
                    store: self.store,
                    data: selectAction,
                    passageName: passageName
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
            bag += combineLatest(self.dataSignal, self.passageName).delay(by: 0.25).onValueDisposePrevious { data, passageName in
                let innerBag = DisposeBag()
                                
                if let selectAction = data?.asEmbarkSelectAction {
                    innerBag += view.addArranged(EmbarkSelectAction(
                        store: self.store,
                        data: selectAction,
                        passageName: passageName
                    )).onValue(callback)
                } else if let textAction = data?.asEmbarkTextAction {
                    innerBag += view.addArranged(EmbarkTextAction(
                        store: self.store,
                        data: textAction,
                        passageName: passageName
                    )).onValue(callback)
                } else if let numberAction = data?.asEmbarkNumberAction {
                    innerBag += view.addArranged(EmbarkNumberAction(
                        store: self.store,
                        data: numberAction,
                        passageName: passageName
                    )).onValue(callback)
                }
                
                return innerBag
            }
            
            return bag
        })
    }
}
