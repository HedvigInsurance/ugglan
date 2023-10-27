import Apollo
import Flow
import Foundation
import UIKit
import hCore
import hGraphQL

struct Message: Equatable, Hashable { static func == (lhs: Message, rhs: Message) -> Bool {
    lhs.globalId == rhs.globalId
}

func hash(into hasher: inout Hasher) { hasher.combine(globalId) }

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
    let statusMessage: String?

    private let cachedComputedProperties: CachedComputedProperties?

    let listSignal: ReadSignal<[ChatListContent]>?
    let editingDisabledSignal = ReadWriteSignal<Bool>(false)
    let onEditCallbacker = Callbacker<Void>()

    var onTapSignal: Signal<URL> { onTapCallbacker.providedSignal }

    let onTapCallbacker = Callbacker<URL>()

    enum ResponseType: Equatable {
        case singleSelect(options: [SingleSelectOption])
        case text, none
    }

    enum MessageType: Equatable {
        static func == (lhs: Message.MessageType, rhs: Message.MessageType) -> Bool {
            switch (lhs, rhs) {
            case (.file, .file): return true
            case (.text, .text): return true
            case (.image, .image): return true
            case (.video, .video): return true
            case (.gif, .gif): return true
            default: return false
            }
        }

        var isRichType: Bool {
            switch self {
            case .text: return false
            case .image: return true
            case .video: return true
            case .gif: return true
            case .file: return true
            case .crossSell: return true
            }
        }

        var isImageType: Bool {
            switch self {
            case .image: return true
            default: return false
            }
        }

        var isVideoType: Bool {
            switch self {
            case .video: return true
            default: return false
            }
        }

        var isGIFType: Bool {
            switch self {
            case .gif: return true
            default: return false
            }
        }

        var isCrossSell: Bool {
            switch self {
            case .crossSell: return true
            default: return false
            }
        }

        var isVideoOrImageType: Bool { isImageType || isVideoType || isGIFType }

        case text
        case image(url: URL?)
        case video(url: URL?)
        case file(url: URL?)
        case gif(url: URL?)
        case crossSell(url: URL?)
    }

    var hasTypingIndicatorNext: Bool {
        cachedComputedProperties?
            .compute("hasTypingIndicatorNext") { () -> Bool in
                guard let list = self.listSignal?.value else { return false }

                guard let myIndex = list.firstIndex(of: .left(self)) else { return false }
                let nextIndex = myIndex - 1

                if !list.indices.contains(nextIndex) { return false }

                return list[nextIndex].right != nil
            } ?? false
    }

    var next: Message? {
        cachedComputedProperties?
            .compute("next") { () -> Message? in guard let list = self.listSignal?.value else { return nil }

                guard let myIndex = list.firstIndex(of: .left(self)) else { return nil }
                let nextIndex = myIndex - 1

                if !list.indices.contains(nextIndex) { return nil }

                return list[nextIndex].left
            }
    }

    var previous: Message? {
        cachedComputedProperties?
            .compute("previous") { () -> Message? in
                guard let list = self.listSignal?.value else { return nil }

                guard let myIndex = list.firstIndex(of: .left(self)) else { return nil }
                let previousIndex = myIndex + 1

                if !list.indices.contains(previousIndex) { return nil }

                return list[previousIndex].left
            }
    }

    enum Radius {
        case halfHeight
        case fixed(value: CGFloat)
    }

    var bottomRightRadius: Radius {
        if fromMyself { if isRelatedToNextMessage { return .fixed(value: 3) } else { return .fixed(value: 6) } }

        return .fixed(value: 6)
    }

    var bottomLeftRadius: Radius {
        if !fromMyself {
            if isRelatedToNextMessage { return .fixed(value: 3) } else { return .fixed(value: 6) }
        }

        return .fixed(value: 6)
    }

    var topRightRadius: Radius {
        if fromMyself {
            if isRelatedToPreviousMessage { return .fixed(value: 3) } else { return .fixed(value: 6) }
        }

        return .fixed(value: 6)
    }

    var topLeftRadius: Radius {
        if !fromMyself {
            if isRelatedToPreviousMessage { return .fixed(value: 3) } else { return .fixed(value: 6) }
        }

        return .fixed(value: 6)
    }

    func absoluteRadiusValue(radius: Radius, view: UIView) -> CGFloat {
        switch radius {
        case let .fixed(value): return value
        case .halfHeight: return min(view.frame.height / 2, 20)
        }
    }

    init(
        from message: Message
    ) {
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
        cachedComputedProperties = message.cachedComputedProperties
        statusMessage = message.statusMessage
    }

    init(
        from message: Message,
        listSignal: ReadSignal<[ChatListContent]>?
    ) {
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
        statusMessage = message.statusMessage

        if listSignal != nil {
            cachedComputedProperties = message.cachedComputedProperties
        } else {
            cachedComputedProperties = nil
        }
    }

    init(
        from message: OctopusGraphQL.MessageFragment,
        listSignal: ReadSignal<[ChatListContent]>?
    ) {
        globalId = message.id
        id = message.id
        richTextCompatible = true
        if let listSignal = listSignal {
            cachedComputedProperties = CachedComputedProperties(listSignal.toVoid().plain())
        } else {
            cachedComputedProperties = nil
        }
        if let text = message.fragments.chatMessageTextFragment {
            body = text.text
            responseType = .text
            placeholder = nil
            keyboardType = nil
            textContentType = nil
            if text.text.isGIFURL {
                type = .gif(url: URL(string: text.text))
            } else if text.text.isCrossSell {
                type = .crossSell(url: URL(string: text.text))
            } else {
                type = .text
            }
        } else if let file = message.fragments.chatMessageFileFragment {
            body = ""
            responseType = .text
            placeholder = nil
            keyboardType = nil
            textContentType = nil

            switch file.mimeType {
            case "image/jpeg", "image/png", "image/gif":
                type = .image(url: URL(string: file.signedUrl))
            case "video/webm", "video/ogg", "video/mp4", "video/quicktime":
                type = .video(url: URL(string: file.signedUrl))
            default: type = .file(url: URL(string: file.signedUrl))
            }
        } else {
            body = "Oj något gick fel"
            responseType = .text
            placeholder = nil
            keyboardType = nil
            textContentType = nil
            type = .text
        }

        fromMyself = message.sender == .member
        statusMessage = nil
        let timeIntervalSince1970 = message.sentAt.localDateToIso8601Date?.timeIntervalSince1970
        let timeStampInt = timeIntervalSince1970 ?? 0
        timeStamp = timeStampInt
        self.listSignal = listSignal
    }
}
