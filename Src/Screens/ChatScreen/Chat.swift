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

struct Message {
    let body: String
    let fromMyself: Bool
    private let index: Int
    private let listSignal: ReadWriteSignal<[Message]?>
    
    var next: Message? {
        guard let list = listSignal.value else {
            return nil
        }
        
        return list[list.index(after: index)]
    }
    
    var previous: Message? {
        guard let list = listSignal.value else {
            return nil
        }
        
        return list[list.index(before: index)]
    }
    
    init(from message: ChatMessagesQuery.Data.Message, index: Int, listSignal: ReadWriteSignal<[Message]?>) {
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
        
        let bubble = UIView()
        bubble.backgroundColor = .purple
        
        bubble.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(300)
        }
        
        containerView.addArrangedSubview(bubble)
        
        let contentContainer = UIStackView()
        contentContainer.layoutMargins = UIEdgeInsets(horizontalInset: 10, verticalInset: 10)
        contentContainer.isLayoutMarginsRelativeArrangement = true
        
        bubble.addSubview(contentContainer)
        
        contentContainer.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        return (containerView, { message in
            let bag = DisposeBag()
                        
            containerView.alignment = message.fromMyself ? .trailing : .leading
            
            let label = MultilineLabel(value: message.body, style: TextStyle.body.colored(message.fromMyself ? .white : .offBlack))
            bag += contentContainer.addArranged(label)
            
            bag += bubble.didLayoutSignal.onValue({ _ in
                bubble.layer.cornerRadius = min(10, bubble.frame.height / 2)
            })
            
            bubble.backgroundColor = message.fromMyself ? .purple : .white
            
            return bag
        })
    }
}

extension Chat: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()

        let viewController = UIViewController()
        viewController.preferredContentSize = CGSize(width: 0, height: UIScreen.main.bounds.height - 100)

        Chat.didOpen()

        bag += Disposer {
            Chat.didClose()
        }
        
        let sectionStyle = SectionStyle(
            rowInsets: UIEdgeInsets(
                top: 10,
                left: 20,
                bottom: 10,
                right: 20
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
        tableKit.view.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        bag += tableKit.delegate.willDisplayCell.onValue { cell, _ in
            cell.contentView.transform =  CGAffineTransform(scaleX: 1, y: -1)
        }
        
        bag += client.fetch(query: ChatMessagesQuery()).valueSignal.compactMap { $0.data?.messages.compactMap { message in message } }.map { messages -> [Message] in
            let listSignal = ReadWriteSignal<[Message]?>(nil)
            
            let messagesList = messages.enumerated().map { (index, message) in Message(from: message, index: index, listSignal: listSignal) }
            listSignal.value = messagesList
            
            return messagesList
        }.onValue({ messages in
            tableKit.table = Table(rows: messages)
        })
        
        bag += client.subscribe(subscription: ChatMessagesSubscription()).onValue({ data in
            print(data)
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
