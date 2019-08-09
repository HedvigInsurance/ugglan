//
//  SingleSelectList.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-01.
//

import Apollo
import Flow
import Foundation
import UIKit

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
    func materialize(events _: ViewableEvents) -> (UIStackView, Disposable) {
        let bag = DisposeBag()
        let view = UIStackView()
        view.isLayoutMarginsRelativeArrangement = true
        view.axis = .vertical

        bag += optionsSignal.animated(style: SpringAnimationStyle.lightBounce()) { options in
            view.subviews.forEach({ view in
                view.isHidden = true
                view.transform = CGAffineTransform(translationX: 0, y: 200)
                view.layoutIfNeeded()
                view.tag = 1
            })

            let containerView = UIStackView()
            containerView.isHidden = true
            containerView.axis = .vertical
            containerView.spacing = 15
            containerView.layoutMargins = UIEdgeInsets(horizontalInset: 20, verticalInset: 20)
            containerView.isLayoutMarginsRelativeArrangement = true
            view.addArrangedSubview(containerView)
            containerView.layoutSuperviewsIfNeeded()

            bag += options.map({ option in
                let innerBag = DisposeBag()
                let button = Button(title: option.text, type: .outline(borderColor: .purple, textColor: .purple))

                innerBag += button.onTapSignal.withLatestFrom(self.currentGlobalIdSignal.atOnce().plain()).compactMap { $1 }.onValue { globalId in

                    switch option.type {
                    case let .link(view):
                        if view == .offer {
                            self.navigateCallbacker.callAll(with: .offer)
                        } else if view == .dashboard {
                            self.navigateCallbacker.callAll(with: .dashboard)
                        }
                    case .selection:
                        self.client.perform(
                            mutation: SendChatSingleSelectResponseMutation(globalId: globalId, selectedValue: option.value)
                        )
                    }
                }

                innerBag += containerView.addArranged(button.wrappedIn({
                    let stackView = UIStackView()
                    stackView.alignment = .leading
                    return stackView
                }()))

                return innerBag
            })

        }.animated(style: SpringAnimationStyle.lightBounce(), animations: { _ in
            view.subviews.forEach({ view in
                if view.tag == 1 {
                    view.removeFromSuperview()
                } else {
                    view.isHidden = false
                    view.layoutSuperviewsIfNeeded()
                }
            })

        })

        return (view, bag)
    }
}
