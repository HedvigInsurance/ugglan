//
//  ChatPreview.swift
//  project
//
//  Created by Sam Pettersson on 2019-05-07.
//

import Foundation
import UIKit
import Flow
import Apollo

struct ChatPreview {
    let client: ApolloClient
    let presentingViewController: UIViewController
    
    init(presentingViewController: UIViewController, client: ApolloClient = ApolloContainer.shared.client) {
        self.presentingViewController = presentingViewController
        self.client = client
    }
}

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

extension ChatPreviewSubscription.Data.Message: Equatable {
    public static func == (lhs: ChatPreviewSubscription.Data.Message, rhs: ChatPreviewSubscription.Data.Message) -> Bool {
        return lhs.globalId == rhs.globalId
    }
}

extension ChatPreview: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let containerView = UIStackView()
        containerView.isLayoutMarginsRelativeArrangement = true
        containerView.layoutMargins = UIEdgeInsets(horizontalInset: 15, verticalInset: 15)
        containerView.axis = .vertical
        containerView.spacing = 15
        containerView.isHidden = true
        
        let bag = DisposeBag()
        
        let symbolIconContainer = UIStackView()
        symbolIconContainer.axis = .vertical
        symbolIconContainer.alignment = .leading
        symbolIconContainer.isLayoutMarginsRelativeArrangement = true
        symbolIconContainer.edgeInsets = UIEdgeInsets(horizontalInset: 15, verticalInset: 0)

        let symbolIcon = Icon(icon: Asset.symbol, iconWidth: 20)
        symbolIconContainer.addArrangedSubview(symbolIcon)
        
        containerView.addArrangedSubview(symbolIconContainer)
        
        let messageBubble = MessageBubble()
        bag += containerView.addArranged(messageBubble)
        
        let openChatButton = Button(title: "Svara", type: .standardSmall(backgroundColor: .purple, textColor: .white))
        bag += containerView.addArranged(openChatButton.wrappedIn(UIStackView()).wrappedIn(UIStackView())) { stackView in
            stackView.axis = .vertical
            stackView.alignment = .trailing
        }
        
        bag += containerView.addArranged(Spacing(height: 10))
        
        bag += containerView.addArranged(Divider(backgroundColor: .lightGray))
        
        bag += openChatButton.onTapSignal.onValue { _ in
            dashboardOpenFreeTextChat(self.presentingViewController)
        }
        
        func animateVisibility(visible: Bool) {
            bag += Signal(after: 0.5).animated(style: SpringAnimationStyle.lightBounce(), animations: { _ in
                containerView.isHidden = !visible
                containerView.layoutSuperviewsIfNeeded()
            })
        }
        
        let freeChatFromBoId: GraphQLID = "free.chat.from.bo"
        
        bag += client.fetch(query: ChatPreviewQuery()).valueSignal
            .compactMap { $0.data?.messages }
            .compactMap { $0.compactMap { $0 } }
            .onValue { messages in
            guard let firstMessage = messages.first, let text = firstMessage.body.asMessageBodyText?.text, firstMessage.id == freeChatFromBoId else {
                animateVisibility(visible: false)
                return
            }
            
            animateVisibility(visible: true)
            messageBubble.textSignal.value = text
        }
        
        bag += self.client.subscribe(
            subscription: ChatPreviewSubscription(mostRecentTimestamp: String(Date().currentTimeMillis()))
        ).compactMap { $0.data?.messages?.compactMap { $0 } }.distinct().onValue { messages in
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
