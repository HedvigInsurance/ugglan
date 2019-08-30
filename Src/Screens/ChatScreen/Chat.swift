//
//  Chat.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-06.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Form
import Presentation
import UIKit

struct Chat {
    let client: ApolloClient

    init(client: ApolloClient = ApolloContainer.shared.client) {
        self.client = client
    }
}

struct SingleSelectOption: Equatable {
    let type: OptionType
    let text: String
    let value: String

    enum ViewType: Equatable {
        case dashboard, offer

        static func from(rawValue: String) -> ViewType {
            switch rawValue {
            case "DASHBOARD":
                return .dashboard
            case "OFFER":
                return .offer
            default:
                return .dashboard
            }
        }
    }

    enum OptionType: Equatable {
        case selection, link(view: ViewType)
    }
}

typealias ChatListContent = Either<Message, TypingIndicator>

struct Message: Equatable, Hashable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.globalId == rhs.globalId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(globalId)
    }

    let globalId: GraphQLID
    let id: GraphQLID
    let body: String
    let fromMyself: Bool
    let responseType: ResponseType
    private let index: Int
    private let getList: () -> [ChatListContent]

    enum ResponseType: Equatable {
        case singleSelect(options: [SingleSelectOption]), text
    }

    var next: Message? {
        let nextIndex = index - 1
        let list = getList()

        if !list.indices.contains(nextIndex) {
            return nil
        }

        return list[nextIndex].left
    }

    var previous: Message? {
        let previousIndex = index + 1
        let list = getList()

        if !list.indices.contains(previousIndex) {
            return nil
        }

        return list[previousIndex].left
    }

    enum Radius {
        case halfHeight, fixed(value: CGFloat)
    }

    var bottomRightRadius: Radius {
        if let nextFromMyself = next?.fromMyself, nextFromMyself == fromMyself {
            return .fixed(value: 5)
        }

        return .halfHeight
    }

    var bottomLeftRadius: Radius {
        return .halfHeight
    }

    var topRightRadius: Radius {
        if let prevFromMyself = previous?.fromMyself, prevFromMyself == fromMyself {
            return .fixed(value: 5)
        }

        return .halfHeight
    }

    var topLeftRadius: Radius {
        return .halfHeight
    }

    func absoluteRadiusValue(radius: Radius, view: UIView) -> CGFloat {
        switch radius {
        case let .fixed(value):
            return value
        case .halfHeight:
            return min(view.frame.height / 2, 20)
        }
    }

    init(from message: Message, index: Int) {
        body = message.body
        fromMyself = message.fromMyself
        self.index = index
        getList = message.getList
        globalId = message.globalId
        id = message.id
        responseType = message.responseType
    }

    init(from message: MessageData, index: Int, getList: @escaping () -> [ChatListContent]) {
        globalId = message.globalId
        id = message.id

        if let singleSelect = message.body.asMessageBodySingleSelect {
            body = singleSelect.text

            if let choices = singleSelect.choices?.compactMap({ $0 }) {
                let options = choices.compactMap { choice -> SingleSelectOption? in
                    if let selection = choice.asMessageBodyChoicesSelection {
                        return SingleSelectOption(
                            type: .selection,
                            text: selection.text,
                            value: selection.value
                        )
                    } else if let link = choice.asMessageBodyChoicesLink, let view = link.view {
                        return SingleSelectOption(
                            type: .link(view: SingleSelectOption.ViewType.from(rawValue: view.rawValue)),
                            text: link.text,
                            value: link.value
                        )
                    }

                    return nil
                }
                responseType = .singleSelect(options: options)
            } else {
                responseType = .text
            }
        } else if let multipleSelect = message.body.asMessageBodyMultipleSelect {
            body = multipleSelect.text
            responseType = .text
        } else if let text = message.body.asMessageBodyText {
            body = text.text
            responseType = .text
        } else if let number = message.body.asMessageBodyNumber {
            body = number.text
            responseType = .text
        } else if let audio = message.body.asMessageBodyAudio {
            body = audio.text
            responseType = .text
        } else if let bankIdCollect = message.body.asMessageBodyBankIdCollect {
            body = bankIdCollect.text
            responseType = .text
        } else if let paragraph = message.body.asMessageBodyParagraph {
            body = paragraph.text
            responseType = .text
        } else if let file = message.body.asMessageBodyFile {
            body = file.text
            responseType = .text
        } else if let undefined = message.body.asMessageBodyUndefined {
            body = undefined.text
            responseType = .text
        } else {
            body = "Oj något gick fel"
            responseType = .text
        }

        fromMyself = message.header.fromMyself
        self.index = index
        self.getList = getList
    }
}

extension Message: Reusable {
    static func makeAndConfigure() -> (make: UIView, configure: (Message) -> Disposable) {
        let containerView = UIStackView()
        containerView.axis = .vertical
        containerView.alignment = .trailing

        let spacingContainer = UIStackView()
        spacingContainer.insetsLayoutMarginsFromSafeArea = false
        spacingContainer.isLayoutMarginsRelativeArrangement = true
        containerView.addArrangedSubview(spacingContainer)

        let bubble = UIView()
        bubble.backgroundColor = .primaryTintColor

        bubble.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(300)
        }

        spacingContainer.addArrangedSubview(bubble)

        let contentContainer = UIStackView()
        contentContainer.layoutMargins = UIEdgeInsets(horizontalInset: 10, verticalInset: 10)
        contentContainer.isLayoutMarginsRelativeArrangement = true
        contentContainer.insetsLayoutMarginsFromSafeArea = false

        bubble.addSubview(contentContainer)

        contentContainer.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }

        return (containerView, { message in
            let bag = DisposeBag()

            if let prevFromMyself = message.previous?.fromMyself, prevFromMyself == message.fromMyself {
                spacingContainer.layoutMargins = UIEdgeInsets(top: 2, left: 20, bottom: 0, right: 20)
            } else {
                spacingContainer.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
            }

            containerView.alignment = message.fromMyself ? .trailing : .leading

            let label = MultilineLabel(value: message.body, style: TextStyle.body.colored(message.fromMyself ? .white : .primaryText))
            bag += contentContainer.addArranged(label)

            bag += bubble.copySignal.onValue { _ in
                UIPasteboard.general.value = message.body
            }

            bag += bubble.didLayoutSignal.onValue({ _ in
                bubble.applyRadiusMaskFor(
                    topLeft: message.absoluteRadiusValue(radius: message.topLeftRadius, view: bubble),
                    bottomLeft: message.absoluteRadiusValue(radius: message.bottomLeftRadius, view: bubble),
                    bottomRight: message.absoluteRadiusValue(radius: message.bottomRightRadius, view: bubble),
                    topRight: message.absoluteRadiusValue(radius: message.topRightRadius, view: bubble)
                )
            })

            bubble.backgroundColor = message.fromMyself ? .primaryTintColor : .secondaryBackground

            return bag
        })
    }
}

class AccessoryViewController<Accessory: Viewable>: UIViewController where Accessory.Events == ViewableEvents, Accessory.Matter: UIView, Accessory.Result == Disposable {
    let accessoryView: Accessory.Matter

    init(accessoryView: Accessory) {
        let (view, disposable) = accessoryView.materialize(events: ViewableEvents(wasAddedCallbacker: Callbacker<Void>()))
        self.accessoryView = view

        let bag = DisposeBag()

        bag += disposable

        super.init(nibName: nil, bundle: nil)

        bag += deallocSignal.onValue { _ in
            bag.dispose()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override var inputAccessoryView: UIView? {
        return accessoryView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        becomeFirstResponder()
    }
}

func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

enum NavigationEvent {
    case dashboard, offer
}

extension Chat: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()

        let currentMessageSignal = ReadWriteSignal<Message?>(nil)
        let typingIndicatorVisibleSignal = ReadWriteSignal<Bool>(false)
        let navigateCallbacker = Callbacker<NavigationEvent>()

        let chatInput = ChatInput(
            currentMessageSignal: currentMessageSignal.readOnly(),
            navigateCallbacker: navigateCallbacker
        )

        let viewController = AccessoryViewController(accessoryView: chatInput)
        viewController.preferredContentSize = CGSize(width: 0, height: UIScreen.main.bounds.height - 100)

        bag += navigateCallbacker.onValue { navigationEvent in
            switch navigationEvent {
            case .offer:
                viewController.present(Offer(), options: [.prefersNavigationBarHidden(true)])
            case .dashboard:
                viewController.present(LoggedIn())
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

        let headerStackView = UIStackView()
        headerStackView.axis = .vertical

        let headerPushView = UIView()
        headerPushView.snp.makeConstraints { make in
            make.height.width.equalTo(0)
        }
        headerStackView.addArrangedSubview(headerPushView)

        let headerSingleInputView = UIView()
        headerStackView.addArrangedSubview(headerSingleInputView)

        let optionsSignal = ReadWriteSignal<[SingleSelectOption]>([])
        let currentGlobalIdSignal = currentMessageSignal.map { message in message?.globalId }

        let singleSelectList = SingleSelectList(
            optionsSignal: optionsSignal.readOnly(),
            currentGlobalIdSignal: currentGlobalIdSignal,
            navigateCallbacker: navigateCallbacker
        )
        bag += headerSingleInputView.add(singleSelectList) { selectListView in
            selectListView.transform = CGAffineTransform(scaleX: 1, y: -1)
            selectListView.snp.makeConstraints { make in
                make.width.height.centerX.centerY.equalToSuperview()
            }
        }

        let tableKit = TableKit<EmptySection, ChatListContent>(table: Table(), style: style, view: nil, bag: bag, headerForSection: nil, footerForSection: nil)
        tableKit.view.keyboardDismissMode = .interactive
        tableKit.view.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableKit.view.contentInsetAdjustmentBehavior = .never
        tableKit.view.tableHeaderView = headerStackView

        bag += currentMessageSignal.compactMap { $0 }.onValue { message in
            switch message.responseType {
            case .text:
                optionsSignal.value = []
                headerStackView.layoutIfNeeded()
                tableKit.view.tableHeaderView = headerStackView
            case let .singleSelect(options):
                optionsSignal.value = options
                headerStackView.layoutIfNeeded()
                tableKit.view.tableHeaderView = headerStackView
            }
        }

        headerStackView.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }

        bag += tableKit.delegate.willDisplayCell.onValue { cell, _ in
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        }

        bag += NotificationCenter.default
            .signal(forName: UIResponder.keyboardWillShowNotification)
            .compactMap { notification in notification.keyboardInfo }
            .animated(mapStyle: { (keyboardInfo) -> AnimationStyle in
                AnimationStyle(options: keyboardInfo.animationCurve, duration: keyboardInfo.animationDuration, delay: 0)
            }, animations: { keyboardInfo in
                headerPushView.snp.remakeConstraints { make in
                    make.height.equalTo(keyboardInfo.endFrame.height + 20)
                }
                headerStackView.layoutIfNeeded()
                tableKit.view.tableHeaderView = headerStackView
            })

        bag += NotificationCenter.default
            .signal(forName: UIResponder.keyboardWillHideNotification)
            .compactMap { notification in notification.keyboardInfo }
            .animated(mapStyle: { (keyboardInfo) -> AnimationStyle in
                AnimationStyle(options: keyboardInfo.animationCurve, duration: keyboardInfo.animationDuration, delay: 0)
            }, animations: { keyboardInfo in
                headerPushView.snp.remakeConstraints { make in
                    make.height.equalTo(keyboardInfo.height)
                }
                headerStackView.layoutIfNeeded()
                tableKit.view.tableHeaderView = headerStackView
            })

        let messagesSignal = ReadWriteSignal<[ChatListContent]>([])

        func fetchMessages() {
            bag += client.fetch(query: ChatMessagesQuery(), cachePolicy: .fetchIgnoringCacheData, queue: DispatchQueue.global(qos: .background))
                .valueSignal
                .compactMap { messages -> [MessageData]? in messages.data?.messages.compactMap { message in message?.fragments.messageData } }
                .atValue({ messages -> Void in
                    guard let message = messages.first else { return }
                    currentMessageSignal.value = Message(from: message, index: 0) { messagesSignal.value }
                })
                .map { messages -> [Message] in
                    messages.enumerated().map { offset, message in Message(from: message, index: offset) { messagesSignal.value } }
                }.map { messages in messages.filter { $0.body != "" } }.onValue({ messages in
                    if messages.count > messagesSignal.value.count {
                        let amountOfNewRows = messages.count - messagesSignal.value.count

                        for i in 0 ... amountOfNewRows {
                            if messages.indices.contains(i) {
                                messagesSignal.value.insert(.left(messages[i]), at: i)
                            }
                        }
                    }
                })
        }

        bag += messagesSignal.compactMap { list -> [ChatListContent] in
            return list.enumerated().compactMap { offset, item -> ChatListContent? in
                if item.right != nil {
                    if offset != 0 {
                        return nil
                    }
                }
                
                return item
            }
        }.onValue { messages in
            let tableAnimation = TableAnimation(sectionInsert: .top, sectionDelete: .top, rowInsert: .top, rowDelete: .fade)
            tableKit.set(Table(rows: messages), animation: tableAnimation)
        }

        fetchMessages()

        bag += client.subscribe(subscription: ChatMessagesSubscription())
            .compactMap { $0.data?.message.fragments.messageData }
            .distinct { oldMessage, newMessage in
                return oldMessage.globalId == newMessage.globalId
            }
            .onValue({ message in
                let newMessage = Message(from: message, index: 0) { messagesSignal.value }

                if let paragraph = message.body.asMessageBodyParagraph {
                    paragraph.text != "" ? messagesSignal.value.insert(.left(newMessage), at: 0) : messagesSignal.value.insert(.right(TypingIndicator()), at: 0)
                } else {
                    messagesSignal.value.insert(.left(newMessage), at: 0)
                }

                if !(newMessage.fromMyself == true && newMessage.responseType != Message.ResponseType.text) {
                    currentMessageSignal.value = newMessage
                }
                
                if message.body.asMessageBodyParagraph != nil {
                    typingIndicatorVisibleSignal.value = true

                    bag += Signal(after: TimeInterval(Double(message.header.pollingInterval) / 1000)).onValue { _ in
                        _ = self.client.fetch(
                            query: ChatMessagesQuery(),
                            cachePolicy: .fetchIgnoringCacheData,
                            queue: DispatchQueue.global(qos: .background)
                        )
                    }
                }
            })

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
