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
    let navigateCallbacker: Callbacker<NavigationEvent>
    
    init(
        optionsSignal: ReadSignal<[SingleSelectOption]>,
        currentGlobalIdSignal: ReadSignal<GraphQLID?>,
        navigateCallbacker: Callbacker<NavigationEvent>,
        client: ApolloClient = ApolloContainer.shared.client
    ) {
        self.optionsSignal = optionsSignal
        self.currentGlobalIdSignal = currentGlobalIdSignal
        self.navigateCallbacker = navigateCallbacker
        self.client = client
    }
}

extension SingleSelectList: Viewable {
    func materialize(events: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let view = UIStackView()
        view.isLayoutMarginsRelativeArrangement = true
        view.axis = .vertical
        view.alignment = .trailing
        
        bag += optionsSignal.compactMap { $0 }.filter { $0.count != 0 }.onValue { options in
            let containerView = UIStackView()
            containerView.axis = .vertical
            containerView.isLayoutMarginsRelativeArrangement = true
            containerView.alignment = .trailing
            containerView.spacing = 15
            containerView.layoutMargins = UIEdgeInsets(horizontalInset: 20, verticalInset: 20)
            view.arrangedSubviews.forEach { view in
                view.removeFromSuperview()
            }
            view.addArrangedSubview(containerView)
            
            bag += options.enumerated().map({ index, option in
                let innerBag = DisposeBag()
                let button = Button(title: option.text, type: .outline(borderColor: .purple, textColor: .purple))
                
                innerBag += button.onTapSignal.withLatestFrom(self.currentGlobalIdSignal.atOnce().plain()).compactMap { $1 }.onValue { globalId in
                    func removeViews() {
                        view.arrangedSubviews.forEach { subView in
                            innerBag += Signal(after: 0).animated(style: SpringAnimationStyle.lightBounce(), animations: { _ in
                                subView.alpha = 0
                            }).animated(style: SpringAnimationStyle.lightBounce(), animations: { _ in
                                subView.removeFromSuperview()
                            })
                        }
                    }
                    switch option.type {
                    case let .link(view):
                        if view == .offer {
                            self.navigateCallbacker.callAll(with: .offer)
                        } else if view == .dashboard {
                            self.navigateCallbacker.callAll(with: .dashboard)
                        }
                        removeViews()
                    case .selection:
                        self.client.perform(
                            mutation: SendChatSingleSelectResponseMutation(globalId: globalId, selectedValue: option.value)
                            ).onResult { _ in
                                removeViews()
                        }
                    }
                }
                
                let buttonWrapper = UIStackView()
                buttonWrapper.isLayoutMarginsRelativeArrangement = true
                buttonWrapper.alignment = .center
                buttonWrapper.alpha = 0
                buttonWrapper.tag = index
                
                innerBag += containerView.addArranged(button.wrappedIn(buttonWrapper))
                
                view.layoutIfNeeded()
                let originalTransform = CGAffineTransform(translationX: buttonWrapper.frame.size.width + 80, y: 0)
                buttonWrapper.transform = originalTransform.scaledBy(x: 0.6, y: 0.6)
                
                innerBag += Signal(after: 0.2 + (Double(index)*0.1)).animated(style: SpringAnimationStyle.lightBounce(), animations: { _ in
                    buttonWrapper.alpha = 1
                    buttonWrapper.transform = CGAffineTransform.identity
                })
                
                return innerBag
            })
            
            }
        
        return (view, bag)
    }
}
