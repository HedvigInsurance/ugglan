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
import Common
import Space
import ComponentKit

struct ChatPreview {
    @Inject var client: ApolloClient
    let presentingViewController: UIViewController

    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
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

        let symbolIcon = Icon(icon: Asset.symbol.image, iconWidth: 20)
        symbolIconContainer.addArrangedSubview(symbolIcon)

        containerView.addArrangedSubview(symbolIconContainer)

        let messageBubbleContainer = UIStackView()
        messageBubbleContainer.axis = .vertical
        messageBubbleContainer.spacing = 8
        containerView.addArrangedSubview(messageBubbleContainer)

        let openChatButton = Button(
            title: String(key: .CHAT_PREVIEW_OPEN_CHAT),
            type: .standardSmall(backgroundColor: .hedvig(.primaryTintColor), textColor: .hedvig(.white))
        )

        bag += containerView.addArranged(openChatButton.wrappedIn(UIStackView()).wrappedIn(UIStackView())) { stackView in
            stackView.axis = .vertical
            stackView.alignment = .trailing
        }

        bag += containerView.addArranged(Spacing(height: 10))

        bag += containerView.addArranged(Divider(backgroundColor: .hedvig(.primaryBorder)))

        let messagesBubbleBag = DisposeBag()
        var handledMessageGlobalIds: [GraphQLID] = []

        func animateVisibility(visible: Bool) {
            bag += containerView.hasWindowSignal
                .atOnce()
                .filter { $0 }
                .take(first: 1)
                .animated(style: SpringAnimationStyle.lightBounce(), animations: { _ in
                    containerView.isHidden = !visible
                    containerView.alpha = visible ? 1 : 0
                    containerView.layoutSuperviewsIfNeeded()
                }).onValue { _ in
                    if !visible {
                        handledMessageGlobalIds = []
                        messagesBubbleBag.dispose()
                    }
                }
        }

        bag += Chat.lastOpenedChatSignal.onValue { _ in
            self.presentingViewController.updateTabBarItemBadge(value: nil)
            animateVisibility(visible: false)
        }

        bag += openChatButton.onTapSignal.onValue { _ in
            self.presentingViewController.present(
                FreeTextChat().withCloseButton,
                style: .modal
            )
        }

        let freeChatFromBoId: GraphQLID = "free.chat.from.bo"
        let subscriptionBag = bag.innerBag()

        func getMessagesToShow(messages: [ChatPreviewQuery.Data.Message]) -> Signal<[ChatPreviewQuery.Data.Message]> {
            return Chat.lastOpenedChatSignal.atOnce().plain().map { lastOpenedChat in
                let messagesToShow = messages.prefix(while: { message -> Bool in
                    message.id == freeChatFromBoId
                }).filter { message -> Bool in
                    message.body.asMessageBodyText != nil
                }.filter { message -> Bool in
                    !message.header.markedAsRead
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

                return messagesToShow
            }
        }

        func loadData() {
            bag += client.fetch(query: ChatPreviewQuery(), cachePolicy: .fetchIgnoringCacheData).valueSignal
                .compactMap { $0.data?.messages }
                .compactMap { $0.compactMap { $0 } }
                .plain()
                .flatMapLatest { getMessagesToShow(messages: $0) }
                .onValue { messages in
                    let onlyExistingMessages = messages.elementsEqual(handledMessageGlobalIds, by: { (message, globalId) -> Bool in
                        message.globalId == globalId
                    })

                    self.presentingViewController.updateTabBarItemBadge(
                        value: messages.count > 0 ? String(messages.count) : nil
                    )

                    guard !onlyExistingMessages else {
                        return
                    }

                    let messagesToShow = messages.filter { message -> Bool in
                        handledMessageGlobalIds.first { message.globalId == $0 } == nil
                    }

                    guard messagesToShow.count != 0 else {
                        animateVisibility(visible: false)
                        return
                    }

                    handledMessageGlobalIds.append(contentsOf: messagesToShow.map { $0.globalId })
                    animateVisibility(visible: true)

                    messagesToShow.compactMap { $0.body.asMessageBodyText?.text }.enumerated().forEach { arg in
                        let (offset, text) = arg
                        let messageBubble = MessageBubble(text: text, delay: 0.5 * Double(offset))
                        messagesBubbleBag += messageBubbleContainer.addArranged(messageBubble)
                    }
                }
        }

        func setupSubscription() {
            subscriptionBag += client.subscribe(
                subscription: ChatPreviewSubscription()
            )
            .compactMap { $0.data?.message }
            .distinct()
            .onValue { _ in
                loadData()
            }
        }

        loadData()
        setupSubscription()

        bag += merge(
            NotificationCenter.default.signal(forName: .didOpenChat),
            NotificationCenter.default.signal(forName: UIApplication.willResignActiveNotification)
        ).onValue { _ in
            subscriptionBag.dispose()
        }

        bag += merge(
            NotificationCenter.default.signal(forName: .didCloseChat),
            NotificationCenter.default.signal(forName: UIApplication.willEnterForegroundNotification)
        ).onValue { _ in
            subscriptionBag.dispose()
            loadData()
            setupSubscription()
        }

        return (containerView, bag)
    }
}
