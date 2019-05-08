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
    let presentingViewController: UIViewController

    init(presentingViewController: UIViewController, client: ApolloClient = ApolloContainer.shared.client) {
        self.presentingViewController = presentingViewController
        self.client = client
    }
}

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(timeIntervalSince1970 * 1000)
    }
}

extension ChatPreviewSubscription.Data.Message: Equatable {
    public static func == (lhs: ChatPreviewSubscription.Data.Message, rhs: ChatPreviewSubscription.Data.Message) -> Bool {
        return lhs.globalId == rhs.globalId
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
            }).onValue { _ in
                if !visible {
                    handledMessageGlobalIds = []
                    messagesBubbleBag.dispose()
                }
            }
        }

        bag += Chat.lastOpenedChatSignal.onValue { _ in
            animateVisibility(visible: false)
        }

        bag += openChatButton.onTapSignal.onValue { _ in
            dashboardOpenFreeTextChat(self.presentingViewController)
        }

        let freeChatFromBoId: GraphQLID = "free.chat.from.bo"

        let loadDataBag = bag.innerBag()

        func loadData() {
            loadDataBag += client.fetch(query: ChatPreviewQuery(), cachePolicy: .fetchIgnoringCacheData).valueSignal
                .compactMap { $0.data?.messages }
                .compactMap { $0.compactMap { $0 } }
                .plain()
                .withLatestFrom(Chat.lastOpenedChatSignal.atOnce().plain())
                .onValue { messages, lastOpenedChat in
                    let messagesToShow = messages.prefix(while: { message -> Bool in
                        message.id == freeChatFromBoId
                    }).filter { message -> Bool in
                        message.body.asMessageBodyText != nil
                    }.filter { message -> Bool in
                        guard let timeStamp = Int64(message.header.timeStamp) else {
                            return false
                        }

                        guard let lastOpenedChat = lastOpenedChat else {
                            return true
                        }

                        return lastOpenedChat < timeStamp
                    }.filter { message -> Bool in
                        guard let timeStamp = Int64(message.header.timeStamp) else {
                            return false
                        }

                        let diff = timeStamp - Date().currentTimeMillis()
                        let oneWeek = 604_800 * 1000

                        return diff < oneWeek
                    }.sorted(by: { (a, b) -> Bool in
                        a.header.timeStamp < b.header.timeStamp
                    })

                    let onlyExistingMessages = messagesToShow.elementsEqual(handledMessageGlobalIds, by: { (message, globalId) -> Bool in
                        message.globalId == globalId
                    })

                    guard !onlyExistingMessages else {
                        return
                    }

                    let actualMessagesToShow = messagesToShow.filter { message -> Bool in
                        handledMessageGlobalIds.first { message.globalId == $0 } == nil
                    }

                    guard actualMessagesToShow.count != 0 else {
                        animateVisibility(visible: false)
                        return
                    }

                    handledMessageGlobalIds.append(contentsOf: actualMessagesToShow.map { $0.globalId })
                    animateVisibility(visible: true)

                    actualMessagesToShow.compactMap { $0.body.asMessageBodyText?.text }.enumerated().forEach { arg in
                        let (offset, text) = arg
                        messagesBubbleBag += Signal(after: 0.5 * Double(offset)).onValue { _ in
                            let messageBubble = MessageBubble(text: text)
                            messagesBubbleBag += messageBubbleContainer.addArranged(messageBubble)
                        }
                    }
                }

            loadDataBag += client.subscribe(
                subscription: ChatPreviewSubscription(mostRecentTimestamp: String(Date().currentTimeMillis()))
            ).compactMap { $0.data?.messages?.compactMap { $0 } }
                .distinct()
                .debounce(0.5)
                .withLatestFrom(Chat.lastOpenedChatSignal.atOnce().plain())
                .onValue { messages, lastOpenedChat in
                    let messagesToShow = messages.prefix(while: { message -> Bool in
                        message.id == freeChatFromBoId
                    }).filter { message -> Bool in
                        message.body.asMessageBodyText != nil
                    }.filter { message -> Bool in
                        guard let timeStamp = Int64(message.header.timeStamp) else {
                            return false
                        }

                        guard let lastOpenedChat = lastOpenedChat else {
                            return true
                        }

                        return lastOpenedChat < timeStamp
                    }.filter { message -> Bool in
                        guard let timeStamp = Int64(message.header.timeStamp) else {
                            return false
                        }

                        let diff = timeStamp - Date().currentTimeMillis()
                        let oneWeek = 604_800 * 1000

                        return diff < oneWeek
                    }.sorted(by: { (a, b) -> Bool in
                        a.header.timeStamp < b.header.timeStamp
                    })

                    let onlyExistingMessages = messagesToShow.elementsEqual(handledMessageGlobalIds, by: { (message, globalId) -> Bool in
                        message.globalId == globalId
                    })

                    guard !onlyExistingMessages else {
                        return
                    }

                    let actualMessagesToShow = messagesToShow.filter { message -> Bool in
                        handledMessageGlobalIds.first { message.globalId == $0 } == nil
                    }

                    guard actualMessagesToShow.count != 0 else {
                        animateVisibility(visible: false)
                        return
                    }

                    handledMessageGlobalIds.append(contentsOf: messagesToShow.map { $0.globalId })
                    animateVisibility(visible: true)

                    actualMessagesToShow.compactMap { $0.body.asMessageBodyText?.text }.enumerated().forEach { arg in
                        let (offset, text) = arg
                        messagesBubbleBag += Signal(after: 0.5 * Double(offset)).onValue { _ in
                            let messageBubble = MessageBubble(text: text)
                            messagesBubbleBag += messageBubbleContainer.addArranged(messageBubble)
                        }
                    }
                }
        }

        loadData()

        bag += NotificationCenter.default.signal(forName: UIApplication.willResignActiveNotification).onValue { _ in
            loadDataBag.dispose()
        }

        bag += NotificationCenter.default.signal(forName: UIApplication.willEnterForegroundNotification).onValue { _ in
            loadDataBag.dispose()
            loadData()
        }

        return (containerView, bag)
    }
}
