//
//  Message.swift
//  project
//
//  Created by Sam Pettersson on 2019-09-02.
//

import Foundation
import Flow
import Form
import Apollo

struct Message: Equatable, Hashable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.globalId == rhs.globalId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(globalId)
    }

    let globalId: GraphQLID
    let id: GraphQLID
    let placeholder: String?
    let body: String
    let fromMyself: Bool
    let responseType: ResponseType
    private let index: Int
    private let getList: () -> [ChatListContent]

    enum ResponseType: Equatable {
        case singleSelect(options: [SingleSelectOption]), text, none
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
        placeholder = message.placeholder
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
                responseType = .none
            }
            placeholder = nil
        } else if let multipleSelect = message.body.asMessageBodyMultipleSelect {
            body = multipleSelect.text
            responseType = .none
            placeholder = nil
        } else if let text = message.body.asMessageBodyText {
            body = text.text
            responseType = .text
            placeholder = text.placeholder
        } else if let number = message.body.asMessageBodyNumber {
            body = number.text
            responseType = .text
            placeholder = number.placeholder
        } else if let audio = message.body.asMessageBodyAudio {
            body = audio.text
            responseType = .none
            placeholder = nil
        } else if let bankIdCollect = message.body.asMessageBodyBankIdCollect {
            body = bankIdCollect.text
            responseType = .none
            placeholder = nil
        } else if let paragraph = message.body.asMessageBodyParagraph {
            body = paragraph.text
            responseType = .none
            placeholder = nil
        } else if let file = message.body.asMessageBodyFile {
            body = file.text
            responseType = .text
            placeholder = nil
        } else if let undefined = message.body.asMessageBodyUndefined {
            body = undefined.text
            responseType = .text
            placeholder = nil
        } else {
            body = "Oj något gick fel"
            responseType = .text
            placeholder = nil
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
