//
//  Message.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-09-12.
//

import Apollo
import Flow
import Foundation
import UIKit

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
    let type: MessageType
    let responseType: ResponseType
    let textContentType: UITextContentType?
    let keyboardType: UIKeyboardType?
    let richTextCompatible: Bool
    let timeStamp: TimeInterval

    let listSignal: ReadSignal<[ChatListContent]>?
    let editingDisabledSignal = ReadWriteSignal<Bool>(false)
    let onEditCallbacker = Callbacker<Void>()

    var onTapSignal: Signal<URL> {
        onTapCallbacker.providedSignal
    }

    let onTapCallbacker = Callbacker<URL>()

    enum ResponseType: Equatable {
        case singleSelect(options: [SingleSelectOption]), text, audio, none
    }

    enum MessageType: Equatable {
        static func == (
            lhs: Message.MessageType,
            rhs: Message.MessageType
        ) -> Bool {
            switch (lhs, rhs) {
            case (.file(_), .file(_)):
                return true
            case (.text, .text):
                return true
            case (.image(_), .image(_)):
                return true
            case (.video(_), .video(_)):
                return true
            default:
                return false
            }
        }

        var isRichType: Bool {
            switch self {
            case .text:
                return false
            case .image:
                return true
            case .video:
                return true
            case .file:
                return true
            }
        }

        var isImageType: Bool {
            switch self {
            case .image:
                return true
            default:
                return false
            }
        }

        var isVideoType: Bool {
            switch self {
            case .video:
                return true
            default:
                return false
            }
        }

        var isVideoOrImageType: Bool {
            return isImageType || isVideoType
        }

        case text, image(url: URL?), video(url: URL?), file(url: URL?)
    }

    var shouldShowEditButton: Bool {
        if richTextCompatible {
            return false
        }

        if editingDisabledSignal.value {
            return false
        }

        if !fromMyself {
            return false
        }

        guard let list = listSignal?.value else {
            return false
        }

        guard let myIndex = list.firstIndex(of: .left(self)) else {
            return false
        }
        guard let indexOfFirstMyself = list.firstIndex(where: { message -> Bool in
            guard let left = message.left else {
                return false
            }

            return left.fromMyself == true
        }) else {
            return false
        }

        return myIndex <= indexOfFirstMyself
    }

    var hasTypingIndicatorNext: Bool {
        guard let list = listSignal?.value else {
            return false
        }

        guard let myIndex = list.firstIndex(of: .left(self)) else {
            return false
        }
        let nextIndex = myIndex - 1

        if !list.indices.contains(nextIndex) {
            return false
        }

        return list[nextIndex].right != nil
    }

    var next: Message? {
        guard let list = listSignal?.value else {
            return nil
        }

        guard let myIndex = list.firstIndex(of: .left(self)) else {
            return nil
        }
        let nextIndex = myIndex - 1

        if !list.indices.contains(nextIndex) {
            return nil
        }

        return list[nextIndex].left
    }

    var previous: Message? {
        guard let list = listSignal?.value else {
            return nil
        }

        guard let myIndex = list.firstIndex(of: .left(self)) else {
            return nil
        }
        let previousIndex = myIndex + 1

        if !list.indices.contains(previousIndex) {
            return nil
        }

        return list[previousIndex].left
    }

    enum Radius {
        case halfHeight, fixed(value: CGFloat)
    }

    var bottomRightRadius: Radius {
        if fromMyself {
            if isRelatedToNextMessage {
                return .fixed(value: 5)
            } else {
                return .halfHeight
            }
        }

        return .halfHeight
    }

    var bottomLeftRadius: Radius {
        if !fromMyself {
            if isRelatedToNextMessage {
                return .fixed(value: 5)
            } else {
                return .halfHeight
            }
        }

        return .halfHeight
    }

    var topRightRadius: Radius {
        if fromMyself {
            if isRelatedToPreviousMessage {
                return .fixed(value: 5)
            } else {
                return .halfHeight
            }
        }

        return .halfHeight
    }

    var topLeftRadius: Radius {
        if !fromMyself {
            if isRelatedToPreviousMessage {
                return .fixed(value: 5)
            } else {
                return .halfHeight
            }
        }

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

    init(from message: Message) {
        body = message.body
        fromMyself = message.fromMyself
        listSignal = message.listSignal
        globalId = message.globalId
        id = message.id
        responseType = message.responseType
        placeholder = message.placeholder
        textContentType = message.textContentType
        keyboardType = message.keyboardType
        richTextCompatible = message.richTextCompatible
        type = message.type
        timeStamp = message.timeStamp
    }

    init(from message: Message, listSignal: ReadSignal<[ChatListContent]>?) {
        body = message.body
        fromMyself = message.fromMyself
        self.listSignal = listSignal
        globalId = message.globalId
        id = message.id
        responseType = message.responseType
        placeholder = message.placeholder
        textContentType = message.textContentType
        keyboardType = message.keyboardType
        richTextCompatible = message.richTextCompatible
        type = message.type
        timeStamp = message.timeStamp
    }

    init(from message: MessageData, listSignal: ReadSignal<[ChatListContent]>?) {
        globalId = message.globalId
        id = message.id
        richTextCompatible = message.header.richTextChatCompatible

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
                            type: .link(
                                view: SingleSelectOption.ViewType.from(rawValue: view.rawValue)
                            ),
                            text: link.text,
                            value: link.value
                        )
                    } else if let link = choice.asMessageBodyChoicesLink {
                        return SingleSelectOption(
                            type: .login,
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
            keyboardType = nil
            textContentType = nil
            type = .text
        } else if let multipleSelect = message.body.asMessageBodyMultipleSelect {
            body = multipleSelect.text
            responseType = .none
            placeholder = nil
            keyboardType = nil
            textContentType = nil
            type = .text
        } else if let text = message.body.asMessageBodyText {
            body = text.text
            responseType = .text
            placeholder = text.placeholder
            keyboardType = UIKeyboardType.from(text.keyboard)
            textContentType = UITextContentType.from(text.textContentType)
            type = .text
        } else if let number = message.body.asMessageBodyNumber {
            body = number.text
            responseType = .text
            placeholder = number.placeholder
            keyboardType = UIKeyboardType.from(number.keyboard)
            textContentType = UITextContentType.from(number.textContentType)
            type = .text
        } else if let audio = message.body.asMessageBodyAudio {
            body = audio.text
            responseType = .audio
            placeholder = nil
            keyboardType = nil
            textContentType = nil
            type = .text
        } else if let bankIdCollect = message.body.asMessageBodyBankIdCollect {
            body = bankIdCollect.text
            responseType = .none
            placeholder = nil
            keyboardType = nil
            textContentType = nil
            type = .text
        } else if let paragraph = message.body.asMessageBodyParagraph {
            body = paragraph.text
            responseType = .none
            placeholder = nil
            keyboardType = nil
            textContentType = nil
            type = .text
        } else if let file = message.body.asMessageBodyFile {
            body = file.text
            responseType = .text
            placeholder = nil
            keyboardType = nil
            textContentType = nil

            switch file.mimeType {
            case "image/jpeg", "image/png", "image/gif":
                type = .image(url: URL(string: file.file.signedUrl))
            case "video/webm", "video/ogg", "video/mp4", "video/quicktime":
                type = .video(url: URL(string: file.file.signedUrl))
            default:
                type = .file(url: URL(string: file.file.signedUrl))
            }
        } else if let undefined = message.body.asMessageBodyUndefined {
            body = undefined.text
            responseType = .text
            placeholder = nil
            keyboardType = nil
            textContentType = nil
            type = .text
        } else {
            body = "Oj något gick fel"
            responseType = .text
            placeholder = nil
            keyboardType = nil
            textContentType = nil
            type = .text
        }

        fromMyself = message.header.fromMyself

        let timeStampInt = Int(message.header.timeStamp) ?? 0
        timeStamp = TimeInterval(timeStampInt / 1000)
        self.listSignal = listSignal
    }
}
