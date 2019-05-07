//
//  ChatPreview.swift
//  project
//
//  Created by Sam Pettersson on 2019-05-07.
//

import Apollo
import Flow
import Foundation
import UIKit

struct ChatPreview {
    let client: ApolloClient

    init(client: ApolloClient = ApolloContainer.shared.client) {
        self.client = client
    }
}

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(timeIntervalSince1970 * 1000)
    }
}

extension ChatPreview: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let containerView = UIStackView()
        containerView.isLayoutMarginsRelativeArrangement = true
        containerView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 15)
        containerView.axis = .vertical
        containerView.spacing = 15
        containerView.isHidden = true

        let bag = DisposeBag()

        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 15
        card.layer.shadowOpacity = 0.15
        card.layer.shadowOffset = CGSize(width: 0, height: 6)
        card.layer.shadowRadius = 8
        card.layer.shadowColor = UIColor.darkGray.cgColor

        let cardContent = UIStackView()
        cardContent.axis = .vertical
        cardContent.isLayoutMarginsRelativeArrangement = true
        cardContent.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 15)
        cardContent.spacing = 15

        let title = UILabel(value: "Nytt meddelande från Hedvig", style: .blockRowTitle)
        cardContent.addArrangedSubview(title)

        let messageBubble = MessageBubble()
        bag += cardContent.addArranged(messageBubble)

        card.addSubview(cardContent)

        cardContent.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        containerView.addArrangedSubview(card)

        let openChatButton = Button(title: "Svara", type: .pillTransparent(backgroundColor: .purple, textColor: .white))
        bag += cardContent.addArranged(openChatButton.wrappedIn(UIStackView()).wrappedIn(UIStackView())) { stackView in
            stackView.axis = .vertical
            stackView.alignment = .trailing
        }

        func animateVisibility(visible: Bool) {
            bag += Signal(after: 0.5).animated(style: SpringAnimationStyle.lightBounce(), animations: { _ in
                containerView.isHidden = !visible
                containerView.layoutSuperviewsIfNeeded()
            })
        }

        let freeChatFromBoId: GraphQLID = "free.chat.from.bo"

        bag += client.fetch(query: ChatPreviewQuery()).valueSignal.compactMap { $0.data?.messages }.compactMap { $0.compactMap { $0 } }.onValue { messages in
            guard let firstMessage = messages.first, let text = firstMessage.body.asMessageBodyText?.text, firstMessage.id == freeChatFromBoId else {
                animateVisibility(visible: false)
                return
            }

            animateVisibility(visible: true)
            messageBubble.textSignal.value = text
        }

        bag += client.subscribe(subscription: ChatPreviewSubscription(mostRecentTimestamp: String(Date().currentTimeMillis()))).compactMap { $0.data?.messages?.compactMap { $0 } }.onValue { messages in
            print(messages.first!.id)
            guard let firstMessage = messages.first, let text = firstMessage.body.asMessageBodyText?.text, firstMessage.id == freeChatFromBoId else {
                animateVisibility(visible: false)
                return
            }

            animateVisibility(visible: true)
            messageBubble.textSignal.value = text
        }

        return (containerView, bag)
    }
}
