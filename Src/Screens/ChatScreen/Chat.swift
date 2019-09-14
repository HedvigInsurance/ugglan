//
//  Chat.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-06.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Apollo
import AVKit
import Flow
import Form
import Presentation
import UIKit

struct Chat {
    let client: ApolloClient
    let reloadChatCallbacker = Callbacker<Void>()

    private var reloadChatSignal: Signal<Void> {
        reloadChatCallbacker.providedSignal
    }

    init(client: ApolloClient = ApolloContainer.shared.client) {
        self.client = client
    }
}

typealias ChatListContent = Either<Message, Either<TypingIndicator, SingleSelectList>>

enum NavigationEvent {
    case dashboard, offer, login
}

extension Chat: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()

        let currentMessageSignal = ReadWriteSignal<Message?>(nil)
        let navigateCallbacker = Callbacker<NavigationEvent>()

        let chatInput = ChatInput(
            currentMessageSignal: currentMessageSignal.readOnly(),
            navigateCallbacker: navigateCallbacker
        )

        let viewController = AccessoryViewController(accessoryView: chatInput)
        viewController.preferredContentSize = CGSize(width: 0, height: UIScreen.main.bounds.height - 70)

        bag += navigateCallbacker.onValue { navigationEvent in
            switch navigationEvent {
            case .offer:
                viewController.present(Offer(), options: [.prefersNavigationBarHidden(true)])
            case .dashboard:
                viewController.present(LoggedIn())
            case .login:
                viewController.present(DraggableOverlay(presentable: BankIDLogin()))
            }
        }

        Chat.didOpen()

        bag += Disposer {
            Chat.didClose()
        }

        let sectionStyle = SectionStyle(
            rowInsets: UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: 0,
                right: 0
            ),
            itemSpacing: 0,
            minRowHeight: 10,
            background: .invisible,
            selectedBackground: .invisible,
            header: .none,
            footer: .none
        )

        let dynamicSectionStyle = DynamicSectionStyle { _ in
            sectionStyle
        }

        let style = DynamicTableViewFormStyle(section: dynamicSectionStyle, form: .default)

        let headerPushView = UIView()
        headerPushView.snp.makeConstraints { make in
            make.height.width.equalTo(0)
        }

        let currentGlobalIdSignal = currentMessageSignal.map { message in message?.globalId }

        let tableKit = TableKit<EmptySection, ChatListContent>(
            table: Table(),
            style: style,
            view: nil,
            headerForSection: nil,
            footerForSection: nil
        )
        tableKit.view.keyboardDismissMode = .interactive
        tableKit.view.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableKit.view.insetsContentViewsToSafeArea = false
        bag += tableKit.delegate.heightForCell.set { tableIndex -> CGFloat in
            let item = tableKit.table[tableIndex]

            if let message = item.left {
                return message.totalHeight
            }
            
            if item.right?.left != nil {
                return 40
            }

            return 0
        }

        tableKit.view.contentInsetAdjustmentBehavior = .never
        if #available(iOS 13.0, *) {
            tableKit.view.automaticallyAdjustsScrollIndicatorInsets = false
        }

        // hack to fix modal dismissing when dragging up in scrollView
        if #available(iOS 13.0, *) {
            bag += tableKit.delegate.willBeginDragging.onValue { _ in
                viewController.isModalInPresentation = true
            }

            bag += tableKit.delegate.willEndDragging.onValue { _ in
                viewController.isModalInPresentation = false
            }
        }

        bag += tableKit.delegate.willDisplayCell.onValue { cell, _ in
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        }

        bag += NotificationCenter.default
            .signal(forName: UIResponder.keyboardWillChangeFrameNotification)
            .compactMap { notification in notification.keyboardInfo }
            .debug()
            .animated(mapStyle: { (keyboardInfo) -> AnimationStyle in
                AnimationStyle(options: keyboardInfo.animationCurve, duration: keyboardInfo.animationDuration, delay: 0)
            }, animations: { keyboardInfo in
                tableKit.view.scrollIndicatorInsets = UIEdgeInsets(top: keyboardInfo.height, left: 0, bottom: 0, right: 0)
                let headerView = UIView()
                headerView.frame = CGRect(x: 0, y: 0, width: 0, height: keyboardInfo.height + 20)
                tableKit.view.tableHeaderView = headerView
            })

        let isEditingSignal = ReadWriteSignal<Bool>(false)
        let messagesSignal = ReadWriteSignal<[ChatListContent]>([])

        bag += isEditingSignal.onValue { isEditing in
            messagesSignal.value.compactMap { $0.left }.forEach { message in
                message.editingDisabledSignal.value = isEditing
            }
        }

        bag += messagesSignal.onValueDisposePrevious({ messages -> Disposable? in
            let innerBag = DisposeBag()

            innerBag += messages.compactMap { message -> Disposable? in
                guard let message = message.left else {
                    return nil
                }

                return message.onTapSignal.onValue { value in
                    let windowBag = DisposeBag()

                    let window = UIWindow()
                    window.backgroundColor = .transparent
                    window.isOpaque = false
                    windowBag.hold(window)
                    let rootViewController = UIViewController()
                    window.rootViewController = rootViewController

                    switch message.type {
                    case .file(url: _):
                        rootViewController.present(SafariView(url: value), options: []).onValue { _ in
                            windowBag.dispose()
                        }
                    case .video(url: _):
                        let player = AVPlayer(url: value)
                        let videoPlayer = VideoPlayer(player: player)

                        player.play()

                        rootViewController.present(videoPlayer, style: .modally(presentationStyle: .overFullScreen, transitionStyle: nil, capturesStatusBarAppearance: true), options: []).onValue {
                            windowBag.dispose()
                        }
                    default:
                        break
                    }

                    window.makeKeyAndVisible()
                }
            }

            return innerBag
        })

        bag += messagesSignal.onValueDisposePrevious { messages -> Disposable? in
            let innerBag = DisposeBag()

            innerBag += messages.map { message -> Disposable in
                return message.left?.onEditCallbacker.addCallback({ _ in
                    guard let firstIndex = messagesSignal.value.firstIndex(where: { message -> Bool in
                        message.left?.fromMyself == true
                    }) else {
                        return
                    }

                    isEditingSignal.value = true

                    messagesSignal.value = messagesSignal.value.enumerated().filter { offset, _ -> Bool in
                        offset > firstIndex
                    }.map { $0.1 }

                    _ = self.client.perform(mutation: EditLastResponseMutation()).onValue { _ in
                    }

                    if let firstMessage = messagesSignal.value.first?.left {
                        currentMessageSignal.value = Message(from: firstMessage, listSignal: nil)
                    }
                }) ?? DisposeBag()
            }

            return innerBag
        }

        let filteredMessagesSignal = messagesSignal.map { messages in
            messages.enumerated().compactMap { offset, item -> ChatListContent? in
                if item.right != nil {
                    if offset != 0 {
                        return nil
                    }
                }

                if item.left?.body == "" && !(item.left?.type.isRichType ?? false) {
                    return nil
                }

                return item
            }
        }
        
        func handleNewMessage(message: MessageData) {
            isEditingSignal.value = false

            let newMessage = Message(from: message, listSignal: filteredMessagesSignal)

            if let paragraph = message.body.asMessageBodyParagraph {
                let firstMessage = filteredMessagesSignal.value.first
                let hasPreviousMessage = firstMessage?.left?.fromMyself == false
                
                if paragraph.text != "" {
                    messagesSignal.value.insert(.left(newMessage), at: 0)
                } else if firstMessage?.right?.left == nil {
                    messagesSignal.value.insert(.make(.make(TypingIndicator(hasPreviousMessage: hasPreviousMessage))), at: 0)
                }
            } else {
                messagesSignal.value.insert(.left(newMessage), at: 0)
            }

            if !(newMessage.fromMyself == true && newMessage.responseType != Message.ResponseType.text) {
                currentMessageSignal.value = Message(from: message, listSignal: nil)
            }

            if message.body.asMessageBodyParagraph != nil {
                bag += Signal(after: TimeInterval(Double(message.header.pollingInterval) / 1000)).onValue { _ in
                    _ = self.client.fetch(
                        query: ChatMessagesQuery(),
                        cachePolicy: .fetchIgnoringCacheData,
                        queue: DispatchQueue.global(qos: .background)
                    )
                }
            }
        }

        let subscriptionBag = bag.innerBag()

        func subscribeToMessages() {
            subscriptionBag += client.subscribe(subscription: ChatMessagesSubscription())
                .compactMap { $0.data?.message.fragments.messageData }
                .debug()
                .distinct { oldMessage, newMessage in
                    oldMessage.globalId == newMessage.globalId
                }
                .onValue(handleNewMessage)
        }

        func fetchMessages() {
            bag += client.fetch(
                query: ChatMessagesQuery(),
                cachePolicy: .fetchIgnoringCacheData,
                queue: DispatchQueue.global(qos: .background)
            )
            .valueSignal
            .compactMap { messages -> [MessageData]? in messages.data?.messages.compactMap { message in message?.fragments.messageData } }
            .atValue({ messages -> Void in
                guard let message = messages.first else { return }
                currentMessageSignal.value = Message(from: message, listSignal: nil)
            })
            .onValue({ messages in
                if messages.count > 1 {
                    messagesSignal.value = messages.map { message in .left(Message(from: message, listSignal: filteredMessagesSignal)) }
                    return
                }
                
                guard let message = messages.first else {
                    return
                }
                
                handleNewMessage(message: message)
            })
        }
        
        bag += NotificationCenter.default.signal(
            forName: UIApplication.willResignActiveNotification
        ).onValue { _ in
            subscriptionBag.dispose()
        }

        bag +=  NotificationCenter.default.signal(
            forName: UIApplication.willEnterForegroundNotification
        ).onValue { _ in
            subscriptionBag.dispose()
            subscribeToMessages()
            fetchMessages()
        }

        bag += reloadChatSignal.onValue { _ in
            messagesSignal.value = []
            currentMessageSignal.value = nil
            self.client.perform(mutation: TriggerResetChatMutation()).onValue { _ in
                fetchMessages()
            }
        }

        subscribeToMessages()

        bag += filteredMessagesSignal.onValue { messages in
            if tableKit.table.isEmpty {
                tableKit.set(Table(rows: messages), animation: .none)

                tableKit.view.visibleCells.forEach { cell in
                    cell.alpha = 0
                }

                bag += Signal(after: 0.25).animated(style: .easeOut(duration: 0.25)) { _ in
                    tableKit.view.visibleCells.forEach { cell in
                        cell.alpha = 1
                    }
                }
            } else {
                let tableAnimation = TableAnimation(sectionInsert: .top, sectionDelete: .top, rowInsert: .top, rowDelete: .fade)
                tableKit.set(Table(rows: messages), animation: tableAnimation)
            }
        }

        bag += Signal(after: 0.25).onValue { _ in
            fetchMessages()
        }
        bag += viewController.install(tableKit)

        return (viewController, Future { _ in
            bag
        })
    }
}

extension Chat: Tabable {
    func tabBarItem() -> UITabBarItem {
        return UITabBarItem(title: "Chat", image: nil, selectedImage: nil)
    }
}
