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
    let body: String
    let fromMyself: Bool
    private let index: Int
    private let listSignal: ReadWriteSignal<[Message]>
    
    var next: Message? {
        let nextIndex = listSignal.value.index(after: index)
        
        if nextIndex > listSignal.value.endIndex {
            return nil
        }
        
        return listSignal.value[nextIndex]
    }
    
    var previous: Message? {
        let previousIndex = listSignal.value.index(before: index)
        
        if previousIndex < listSignal.value.startIndex {
            return nil
        }
        
        return listSignal.value[previousIndex]
    }
    
    var bottomRightRadius: CGFloat {
        return 5
    }
    
    var bottomLeftRadius: CGFloat {
        return 5
    }
    
    var topRightRadius: CGFloat {
        return 5
    }
    
    var topLeftRadius: CGFloat {
        if !fromMyself, let prevFromMyself = previous?.fromMyself, prevFromMyself == fromMyself {
            return 5
        }
        
        return 20
    }
    
    init(from message: Message, index: Int) {
        self.body = message.body
        self.fromMyself = message.fromMyself
        self.index = index
        self.listSignal = message.listSignal
        self.globalId = message.globalId
    }
    
    init(from message: ChatMessagesQuery.Data.Message, index: Int, listSignal: ReadWriteSignal<[Message]>) {
        self.globalId = message.globalId
        
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
        self.listSignal = listSignal
    }
    
    init(from message: ChatMessagesSubscription.Data.Message, index: Int, listSignal: ReadWriteSignal<[Message]>) {
        self.globalId = message.globalId
        
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
        self.listSignal = listSignal
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
                    topLeft: message.topLeftRadius,
                    bottomLeft: message.bottomLeftRadius,
                    bottomRight: message.bottomRightRadius,
                    topRight: message.topRightRadius
                )
                
                // bubble.layer.cornerRadius = min(10, bubble.frame.height / 2)
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
        
        bag += tableKit.delegate.willDisplayCell.onValue { cell, _ in
            cell.contentView.transform =  CGAffineTransform(scaleX: 1, y: -1)
        }
        
        let messagesSignal = ReadWriteSignal<[Message]>([])
        
        bag += client.fetch(query: ChatMessagesQuery())
            .valueSignal
            .compactMap { $0.data?.messages.compactMap { message in message } }
            .atValue({ messages in
                currentGlobalIdSignal.value = messages.first?.globalId
            })
            .map { messages -> [Message] in
            return messages.enumerated().map { (index, message) in Message(from: message, index: index, listSignal: messagesSignal) }
        }.bindTo(messagesSignal)
        
        bag += messagesSignal.compactMap { messages in messages.compactMap { $0.body.count > 0 ? $0 : nil } }.onValue { messages in
            tableKit.set(Table(rows: messages), animation: .automatic, rowIdentifier: { $0.globalId })
        }
        
        bag += client.subscribe(subscription: ChatMessagesSubscription())
            .compactMap { $0.data?.message }
            .onValue({ message in
            var newMessages = messagesSignal.value.map { $0 }
            newMessages.insert(Message(from: message, index: 0, listSignal: messagesSignal), at: 0)
            messagesSignal.value =  newMessages.enumerated().map { index, message in Message(from: message, index: index) }
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
