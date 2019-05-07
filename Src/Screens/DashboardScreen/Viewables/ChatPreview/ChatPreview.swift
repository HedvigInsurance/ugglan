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
        
        let messageBubbleContainer = UIStackView()
        messageBubbleContainer.axis = .vertical
        messageBubbleContainer.spacing = 8
        containerView.addArrangedSubview(messageBubbleContainer)
        
        let openChatButton = Button(title: "Svara", type: .standardSmall(backgroundColor: .purple, textColor: .white))
        bag += containerView.addArranged(openChatButton.wrappedIn(UIStackView()).wrappedIn(UIStackView())) { stackView in
            stackView.axis = .vertical
            stackView.alignment = .trailing
        }
        
        bag += containerView.addArranged(Spacing(height: 10))
        
        bag += containerView.addArranged(Divider(backgroundColor: .lightGray))
        
        let messagesBubbleBag = DisposeBag()
        var handledMessageGlobalIds: [GraphQLID] = []
        
        func animateVisibility(visible: Bool) {
            bag += Signal(after: 0.5).animated(style: SpringAnimationStyle.lightBounce(), animations: { _ in
                containerView.isHidden = !visible
                containerView.alpha = visible ? 1 : 0
            }).onValue({ _ in
                if !visible {
                    messagesBubbleBag.dispose()
                }
            })
        }
        
        bag += openChatButton.onTapSignal.onValue { _ in
            dashboardOpenFreeTextChat(self.presentingViewController)
            animateVisibility(visible: false)
        }
        
        let freeChatFromBoId: GraphQLID = "free.chat.from.bo"
        
        bag += client.fetch(query: ChatPreviewQuery()).valueSignal
            .compactMap { $0.data?.messages }
            .compactMap { $0.compactMap { $0 } }
            .onValue { messages in
                let messagesToShow = messages.prefix(while: { message -> Bool in
                    return message.id == freeChatFromBoId
                }).filter({ message -> Bool in
                    return message.body.asMessageBodyText != nil
                }).filter({ message -> Bool in
                    return handledMessageGlobalIds.first { message.globalId == $0 } == nil
                }).filter({ message -> Bool in
                    guard let timeStamp = Int64(message.header.timeStamp) else {
                        return false
                    }
                    
                    let diff = timeStamp - Date().currentTimeMillis()
                    let oneWeek = 604800 * 1000
                    
                    return diff < oneWeek
                }).sorted(by: { (a, b) -> Bool in
                    a.header.timeStamp < b.header.timeStamp
                })
                
            guard messagesToShow.count != 0 else {
                animateVisibility(visible: false)
                return
            }
                
            handledMessageGlobalIds.append(contentsOf: messagesToShow.map { $0.globalId })
            animateVisibility(visible: true)
                
                messagesToShow.compactMap { $0.body.asMessageBodyText?.text }.enumerated().forEach({ (arg) in
                    let (offset, text) = arg
                    print(text)
                    messagesBubbleBag += Signal(after: 0.5 * Double(offset)).onValue { _ in
                    let messageBubble = MessageBubble(text: text)
                    messagesBubbleBag += messageBubbleContainer.addArranged(messageBubble)
                }
            })
        }
        
        bag += self.client.subscribe(
            subscription: ChatPreviewSubscription(mostRecentTimestamp: String(Date().currentTimeMillis()))
        ).compactMap { $0.data?.messages?.compactMap { $0 } }.distinct().debounce(0.5).onValue { messages in
            let messagesToShow = messages.prefix(while: { message -> Bool in
                return message.id == freeChatFromBoId
            }).filter({ message -> Bool in
                return message.body.asMessageBodyText != nil
            }).filter({ message -> Bool in
                return handledMessageGlobalIds.first { message.globalId == $0 } == nil
            }).filter({ message -> Bool in
                guard let timeStamp = Int64(message.header.timeStamp) else {
                    return false
                }
                
                let diff = timeStamp - Date().currentTimeMillis()
                let oneWeek = 604800 * 1000
                
                return diff < oneWeek
            }).sorted(by: { (a, b) -> Bool in
                a.header.timeStamp < b.header.timeStamp
            })
                        
            guard messagesToShow.count != 0 else {
                animateVisibility(visible: false)
                return
            }
            
            handledMessageGlobalIds.append(contentsOf: messagesToShow.map { $0.globalId })
            animateVisibility(visible: true)
            
            messagesBubbleBag += messagesToShow.compactMap { $0.body.asMessageBodyText?.text }.map({ text in
                let messageBubble = MessageBubble(text: text)
                return messageBubbleContainer.addArranged(messageBubble)
            })
        }
        
        return (containerView, bag)
    }
}
