//
//  Chat.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-12-06.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Flow
import Form
import Presentation
import UIKit
import Apollo

struct Chat {
    let client: ApolloClient
    
    init(client: ApolloClient = ApolloContainer.shared.client) {
        self.client = client
    }
}

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
    private let index: Int
    private let getList: () -> [Message]
    
    var next: Message? {
        let nextIndex = index + 1
        let list = getList()
        
        if nextIndex > list.endIndex {
            return nil
        }
        
        return list[nextIndex]
    }
    
    var previous: Message? {
        let previousIndex = index - 1
        let list = getList()
        
        if previousIndex < list.startIndex {
            return nil
        }
        
        return list[previousIndex]
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
        self.body = message.body
        self.fromMyself = message.fromMyself
        self.index = index
        self.getList = message.getList
        self.globalId = message.globalId
        self.id = message.id
    }
    
    init(from message: ChatMessagesQuery.Data.Message, index: Int, getList: @escaping () -> [Message]) {
        self.globalId = message.globalId
        self.id = message.id
        
        if let singleSelect = message.body.asMessageBodySingleSelect {
            self.body = singleSelect.text
        } else if let multipleSelect = message.body.asMessageBodyMultipleSelect {
            self.body = multipleSelect.text
        } else if let text = message.body.asMessageBodyText {
            self.body = text.text
        } else if let number = message.body.asMessageBodyNumber {
            self.body = number.text
        } else if let audio = message.body.asMessageBodyAudio {
            self.body = audio.text
        } else if let bankIdCollect = message.body.asMessageBodyBankIdCollect {
            self.body = bankIdCollect.text
        } else if let paragraph = message.body.asMessageBodyParagraph {
            self.body = paragraph.text
        } else if let file = message.body.asMessageBodyFile {
            self.body = file.text
        } else if let undefined = message.body.asMessageBodyUndefined {
            self.body = undefined.text
        } else {
            self.body = "Oj något gick fel"
        }
        
        self.fromMyself = message.header.fromMyself
        self.index = index
        self.getList = getList
    }
    
    init(from message: ChatMessagesSubscription.Data.Message, index: Int, getList: @escaping () -> [Message]) {
        self.globalId = message.globalId
        self.id = message.id
        
        if let singleSelect = message.body.asMessageBodySingleSelect {
            self.body = singleSelect.text
        } else if let multipleSelect = message.body.asMessageBodyMultipleSelect {
            self.body = multipleSelect.text
        } else if let text = message.body.asMessageBodyText {
            self.body = text.text
        } else if let number = message.body.asMessageBodyNumber {
            self.body = number.text
        } else if let audio = message.body.asMessageBodyAudio {
            self.body = audio.text
        } else if let bankIdCollect = message.body.asMessageBodyBankIdCollect {
            self.body = bankIdCollect.text
        } else if let paragraph = message.body.asMessageBodyParagraph {
            self.body = paragraph.text
        } else if let file = message.body.asMessageBodyFile {
            self.body = file.text
        } else if let undefined = message.body.asMessageBodyUndefined {
            self.body = undefined.text
        } else {
            self.body = "Oj något gick fel"
        }
        
        self.fromMyself = message.header.fromMyself
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
        spacingContainer.isLayoutMarginsRelativeArrangement = true
        containerView.addArrangedSubview(spacingContainer)
        
        let bubble = UIView()
        bubble.backgroundColor = .purple
        
        bubble.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(300)
        }
        
        spacingContainer.addArrangedSubview(bubble)
        
        let contentContainer = UIStackView()
        contentContainer.layoutMargins = UIEdgeInsets(horizontalInset: 10, verticalInset: 10)
        contentContainer.isLayoutMarginsRelativeArrangement = true
        
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
            
            let label = MultilineLabel(value: message.body, style: TextStyle.body.colored(message.fromMyself ? .white : .offBlack))
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
            
            bubble.backgroundColor = message.fromMyself ? .purple : .white
            
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
    
    required init?(coder aDecoder: NSCoder) {
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
        self.becomeFirstResponder()
    }
}

func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

extension Chat: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()
        
        let currentGlobalIdSignal = ReadWriteSignal<GraphQLID?>(nil)

        let viewController = AccessoryViewController(accessoryView: ChatInput(currentGlobalIdSignal: currentGlobalIdSignal.readOnly()))
        viewController.preferredContentSize = CGSize(width: 0, height: UIScreen.main.bounds.height - 100)

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
        
        let tableKit = TableKit<EmptySection, Message>(table: Table(), style: style, view: nil, bag: bag, headerForSection: nil, footerForSection: nil)
        tableKit.view.keyboardDismissMode = .interactive
        tableKit.view.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableKit.view.contentInsetAdjustmentBehavior = .automatic
        
        bag += tableKit.delegate.willDisplayCell.onValue { cell, _ in
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        }
        
        bag += NotificationCenter.default
            .signal(forName: UIResponder.keyboardWillShowNotification)
            .compactMap { notification in notification.keyboardInfo }
            .animated(mapStyle: { keyboardInfo -> AnimationStyle in
                return AnimationStyle.init(options: keyboardInfo.animationCurve, duration: keyboardInfo.animationDuration, delay: 0)
            }, animations: { keyboardInfo in
                let insets = UIEdgeInsets(top: keyboardInfo.height, left: 0, bottom: 0, right: 0)
                tableKit.view.contentInset = insets
                tableKit.view.scrollIndicatorInsets = insets
                
                tableKit.view.layoutIfNeeded()
            })
        
        bag += NotificationCenter.default
            .signal(forName: UIResponder.keyboardWillHideNotification)
            .compactMap { notification in notification.keyboardInfo }
            .animated(mapStyle: { keyboardInfo -> AnimationStyle in
                return AnimationStyle.init(options: keyboardInfo.animationCurve, duration: keyboardInfo.animationDuration, delay: 0)
            }, animations: { keyboardInfo in
                let insets = UIEdgeInsets(top: keyboardInfo.height, left: 0, bottom: 0, right: 0)
                tableKit.view.contentInset = insets
                tableKit.view.scrollIndicatorInsets = insets
                tableKit.view.layoutIfNeeded()
            })
        
        bag += NotificationCenter.default
            .signal(forName: UIResponder.keyboardWillChangeFrameNotification)
            .compactMap { notification in notification.keyboardInfo }
            .animated(mapStyle: { keyboardInfo -> AnimationStyle in
                return AnimationStyle.init(options: keyboardInfo.animationCurve, duration: keyboardInfo.animationDuration, delay: 0)
            }, animations: { keyboardInfo in
                let insets = UIEdgeInsets(top: keyboardInfo.height, left: 0, bottom: 0, right: 0)
                tableKit.view.contentInset = insets
                tableKit.view.scrollIndicatorInsets = insets
                tableKit.view.layoutIfNeeded()
            })
        
        let messagesSignal = ReadWriteSignal<[Message]>([])
        
        bag += client.fetch(query: ChatMessagesQuery(), cachePolicy: .fetchIgnoringCacheData, queue: DispatchQueue.global(qos: .background))
            .valueSignal
            .compactMap { $0.data?.messages.compactMap { message in message } }
            .atValue({ messages in
                currentGlobalIdSignal.value = messages.first?.globalId
            })
            .map { messages -> [Message] in
                return messages.enumerated().map { (offset, message) in Message(from: message, index: offset) { messagesSignal.value } }
            }.map { messages in messages.filter { $0.body != "" } }.bindTo(messagesSignal)
        
        bag += messagesSignal.compactMap { messages in messages.compactMap { $0.body.count > 0 ? $0 : nil } }.onValue { messages in
            let tableAnimation = tableKit.table.isEmpty ? TableAnimation.none : TableAnimation.automatic
            tableKit.set(Table(rows: messages), animation: tableAnimation, rowIdentifier: { $0.globalId })
        }
        
        bag += client.subscribe(subscription: ChatMessagesSubscription())
            .compactMap { $0.data?.message }
            .onValue({ message in
            var newMessages = messagesSignal.value.map { $0 }
            newMessages.insert(Message(from: message, index: 0) { messagesSignal.value }, at: 0)
            messagesSignal.value = newMessages.enumerated().map { offset, message in Message(from: message, index: offset) }
            currentGlobalIdSignal.value = message.globalId
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
