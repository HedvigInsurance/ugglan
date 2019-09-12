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

extension UIKeyboardType {
    static func from(_ keyboardType: KeyboardType?) -> UIKeyboardType? {
        guard let keyboardType = keyboardType else {
            return nil
        }
        
        switch keyboardType {
        case .default:
            return .default
        case .email:
            return .emailAddress
        case .decimalpad:
            return .decimalPad
        case .numberpad:
            return .numberPad
        case .numeric:
            return .numeric
        case .phone:
            return .phonePad
        case .__unknown(_):
            return .default
        }
    }
}

extension UITextContentType {
    static func from(_ textContentType: TextContentType?) -> UITextContentType? {
        guard let textContentType = textContentType else {
            return nil
        }
        
        switch textContentType {
        case .none:
            return .none
        case .url:
            return .URL
        case .addressCity:
            return .addressCity
        case .addressCityState:
            return .addressCityAndState
        case .addressState:
            return .addressState
        case .countryName:
            return .countryName
        case .creditCardNumber:
            return .creditCardNumber
        case .emailAddress:
            return .emailAddress
        case .familyName:
            return .familyName
        case .fullStreetAddress:
            return .fullStreetAddress
        case .givenName:
            return .givenName
        case .jobTitle:
            return .jobTitle
        case .location:
            return .location
        case .middleName:
            return .middleName
        case .name:
            return .name
        case .namePrefix:
            return .namePrefix
        case .nameSuffix:
            return .nameSuffix
        case .nickName:
            return .nickname
        case .organizationName:
            return .organizationName
        case .postalCode:
            return .postalCode
        case .streetAddressLine1:
            return .streetAddressLine1
        case .streetAddressLine2:
            return .streetAddressLine2
        case .sublocality:
            return .sublocality
        case .telephoneNumber:
            return .telephoneNumber
        case .username:
            return .username
        case .password:
            return .password
        case .__unknown(_):
            return .none
        }
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
    let placeholder: String?
    let body: String
    let fromMyself: Bool
    let type: MessageType
    let responseType: ResponseType
    let textContentType: UITextContentType?
    let keyboardType: UIKeyboardType?
    let richTextCompatible: Bool
    
    private let index: Int
    private let listSignal: ReadSignal<[ChatListContent]>?
    let editingDisabledSignal = ReadWriteSignal<Bool>(false)
    let onEditCallbacker = Callbacker<Void>()
    
    var onTapSignal: Signal<URL> {
        onTapCallbacker.providedSignal
    }
    
    private let onTapCallbacker = Callbacker<URL>()

    enum ResponseType: Equatable {
        case singleSelect(options: [SingleSelectOption]), text, none
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
            case .image(_):
                return true
            case .video(_):
                return true
            case .file(_):
                return true
            }
        }
        
        var isImageType: Bool {
            switch self {
            case .image(_):
                return true
            default:
                return false
            }
        }
        
        var isVideoType: Bool {
            switch self {
            case .video(_):
                return true
            default:
                return false
            }
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
            if let nextFromMyself = next?.fromMyself, nextFromMyself {
                return .fixed(value: 5)
            } else {
                return .halfHeight
            }
        }

        return .halfHeight
    }

    var bottomLeftRadius: Radius {
        if !fromMyself {
            if let nextFromMyself = next?.fromMyself, !nextFromMyself {
                return .fixed(value: 5)
            } else {
                return .halfHeight
            }
        }
        
        return .halfHeight
    }

    var topRightRadius: Radius {
        if fromMyself {
            if let prevFromMyself = previous?.fromMyself, prevFromMyself {
                return .fixed(value: 5)
            } else {
                return .halfHeight
            }
        }

        return .halfHeight
    }

    var topLeftRadius: Radius {
        if !fromMyself {
            if let prevFromMyself = previous?.fromMyself, !prevFromMyself {
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

    init(from message: Message, index: Int) {
        body = message.body
        fromMyself = message.fromMyself
        self.index = index
        listSignal = message.listSignal
        globalId = message.globalId
        id = message.id
        responseType = message.responseType
        placeholder = message.placeholder
        textContentType = message.textContentType
        keyboardType = message.keyboardType
        richTextCompatible = message.richTextCompatible
        type = message.type
    }
    
    init(from message: Message, listSignal: ReadSignal<[ChatListContent]>?) {
        body = message.body
        fromMyself = message.fromMyself
        self.index = message.index
        self.listSignal = listSignal
        globalId = message.globalId
        id = message.id
        responseType = message.responseType
        placeholder = message.placeholder
        textContentType = message.textContentType
        keyboardType = message.keyboardType
        richTextCompatible = message.richTextCompatible
        type = message.type
    }

    init(from message: MessageData, index: Int, listSignal: ReadSignal<[ChatListContent]>?) {
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
            responseType = .none
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
            case "video/webm", "video/ogg", "video/mp4":
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
        spacingContainer.alignment = .fill
        spacingContainer.spacing = 5
        spacingContainer.insetsLayoutMarginsFromSafeArea = false
        spacingContainer.isLayoutMarginsRelativeArrangement = true
        containerView.addArrangedSubview(spacingContainer)

        let bubble = UIView()
        bubble.backgroundColor = .primaryTintColor

        bubble.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(300)
        }

        spacingContainer.addArrangedSubview(bubble)
        
        let editbuttonStackContainer = UIStackView()
        editbuttonStackContainer.axis = .vertical
        editbuttonStackContainer.alignment = .top
        
        spacingContainer.addArrangedSubview(editbuttonStackContainer)
        
        let editButtonViewContainer = UIView()
        editButtonViewContainer.snp.makeConstraints { make in
            make.width.equalTo(20)
        }
        
        editbuttonStackContainer.addArrangedSubview(editButtonViewContainer)
        
        let editButton = UIControl()
        editButtonViewContainer.addSubview(editButton)
        editButton.backgroundColor = .primaryTintColor
        editButton.snp.makeConstraints { make in
            make.width.height.equalTo(20)
        }
        editButton.layer.cornerRadius = 10
        
        let editButtonIcon = UIImageView(image: Asset.editIcon.image)
        editButtonIcon.contentMode = .scaleAspectFit
        editButton.addSubview(editButtonIcon)
        
        editButtonIcon.snp.makeConstraints { make in
            make.height.width.equalToSuperview().multipliedBy(0.5)
            make.center.equalToSuperview()
        }
        
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
            
            UIView.setAnimationsEnabled(false)
            
            editbuttonStackContainer.animationSafeIsHidden = !message.shouldShowEditButton
            
            bag += editButton.signal(for: .touchUpInside).onValue({ _ in
                message.onEditCallbacker.callAll()
            })
            
            func applyRounding() {
                bubble.applyRadiusMaskFor(
                    topLeft: message.absoluteRadiusValue(radius: message.topLeftRadius, view: bubble),
                    bottomLeft: message.absoluteRadiusValue(radius: message.bottomLeftRadius, view: bubble),
                    bottomRight: message.absoluteRadiusValue(radius: message.bottomRightRadius, view: bubble),
                    topRight: message.absoluteRadiusValue(radius: message.topRightRadius, view: bubble)
                )
            }
            
            func applySpacing() {
                if message.type.isVideoType || message.type.isImageType {
                    contentContainer.layoutMargins = UIEdgeInsets.zero
                } else {
                    contentContainer.layoutMargins = UIEdgeInsets(horizontalInset: 10, verticalInset: 10)
                }
                
                if let prevFromMyself = message.previous?.fromMyself, prevFromMyself == message.fromMyself {
                    spacingContainer.layoutMargins = UIEdgeInsets(top: 2, left: 20, bottom: 0, right: 20)
                } else {
                    spacingContainer.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
                }
            }
            
            bag += message.listSignal?.toVoid().animated(style: SpringAnimationStyle.lightBounce(), animations: { _ in
                editbuttonStackContainer.animationSafeIsHidden = !message.shouldShowEditButton
                editbuttonStackContainer.alpha = message.shouldShowEditButton ? 1 : 0
                
                applySpacing()
                applyRounding()
                
                spacingContainer.layoutSuperviewsIfNeeded()
            })

            containerView.alignment = message.fromMyself ? .trailing : .leading
            
            let messageTextColor: UIColor = message.fromMyself ? .white : .primaryText
                        
            switch message.type {
            case let .image(url):
                let imageView = UIImageView()
                
                DispatchQueue.global(qos: .background).async {
                    if let url = url, let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                        
                        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)

                        image.draw(at: CGPoint.zero)

                        let decodedImage = UIGraphicsGetImageFromCurrentImageContext()
                        
                        UIGraphicsEndImageContext()
                        
                        DispatchQueue.main.async {
                            imageView.image = decodedImage
                        }
                    }
                }
                
                imageView.snp.makeConstraints { make in
                    make.height.equalTo(200)
                }
                
                contentContainer.addArrangedSubview(imageView)
                
                bag += {
                    imageView.removeFromSuperview()
                }
            case let .file(url):
                let textStyle = TextStyle.chatBodyUnderlined.colored(messageTextColor)
                
                let text = String(key: .CHAT_FILE_DOWNLOAD)
                
                let styledText = StyledText(text: text, style: textStyle)
                
                let label = MultilineLabel(styledText: styledText)
                bag += contentContainer.addArranged(label) { view in
                    let linkTapGestureRecognizer = UITapGestureRecognizer()
                    bag += contentContainer.install(linkTapGestureRecognizer)
                    
                    bag += linkTapGestureRecognizer.signal(forState: .recognized).onValue { _ in
                        guard let url = url else { return }
                        message.onTapCallbacker.callAll(with: url)
                    }
                }
            case .text:
                let label = MultilineLabel(
                    value: message.body,
                    style: TextStyle.chatBody.colored(messageTextColor)
                )
                bag += contentContainer.addArranged(label)
            default:
                break
            }

            if !message.type.isRichType {
                bag += bubble.copySignal.onValue { _ in
                    UIPasteboard.general.value = message.body
                }
            }

            bag += bubble.didLayoutSignal.onValue({ _ in
                applyRounding()
            })
            
            applySpacing()

            bubble.backgroundColor = message.fromMyself ? .primaryTintColor : .secondaryBackground
            
            UIView.setAnimationsEnabled(true)

            return bag
        })
    }
}
