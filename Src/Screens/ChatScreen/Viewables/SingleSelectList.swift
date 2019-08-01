//
//  SingleSelectList.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-01.
//

import Foundation
import Flow
import UIKit
import Apollo

struct SingleSelectList {
    let optionsSignal: ReadSignal<[SingleSelectOption]>
    let currentGlobalIdSignal: ReadSignal<GraphQLID?>
    let client: ApolloClient
    
    init(
        optionsSignal: ReadSignal<[SingleSelectOption]>,
        currentGlobalIdSignal: ReadSignal<GraphQLID?>,
        client: ApolloClient = ApolloContainer.shared.client
    ) {
        self.optionsSignal = optionsSignal
        self.currentGlobalIdSignal = currentGlobalIdSignal
        self.client = client
    }
}

extension SingleSelectList: Viewable {
    func materialize(events: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let view = UIStackView()
        view.isLayoutMarginsRelativeArrangement = true
        view.axis = .vertical
        
        bag += optionsSignal.latestTwo().filter(predicate: { a, b -> Bool in
            a != b
        }).animated(style: SpringAnimationStyle.lightBounce()) { options, _ in
            view.subviews.forEach({ view in
                view.isHidden = true
                view.transform = CGAffineTransform(translationX: 0, y: 200)
            })
            }.animated(style: SpringAnimationStyle.lightBounce(), animations: { options, _ in
                let containerView = UIStackView()
                containerView.axis = .vertical
                containerView.spacing = 15
                containerView.layoutMargins = UIEdgeInsets(horizontalInset: 20, verticalInset: 20)
                containerView.isLayoutMarginsRelativeArrangement = true
                view.addArrangedSubview(containerView)
                
                bag += options.map({ option in
                    let innerBag = DisposeBag()
                    let button = Button(title: option.text, type: .pillTransparent(backgroundColor: .purple, textColor: .white))
                    
                    innerBag += button.onTapSignal.withLatestFrom(self.currentGlobalIdSignal.atOnce().plain()).compactMap { $1 }.onValueDisposePrevious({ globalId in
                        
                        print("hello")
                        
                        return self.client.perform(mutation: SendChatSingleSelectResponseMutation(globalId: globalId, selectedValue: option.value)).disposable
                    })
                    
                    innerBag += containerView.addArranged(button)
                    
                    return innerBag
                })
            })
        
        return (view, bag)
    }
}
