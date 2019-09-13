//
//  Message.swift
//  project
//
//  Created by Sam Pettersson on 2019-09-02.
//

import Foundation
import Flow
import Form
import UIKit
import Kingfisher

extension Message: Reusable {
    var largerMarginTop: CGFloat {
        20
    }
    
    var smallerMarginTop: CGFloat {
        2
    }
    
    /// identifies if message belongs logically to the previous message
    var isRelatedToPreviousMessage: Bool {
        return previous?.fromMyself == fromMyself
    }
    
    /// calculates the total height that is required to render this message, including margins
    var totalHeight: CGFloat {
        if type.isVideoOrImageType {
            let constantHeight: CGFloat = 200
            
            if isRelatedToPreviousMessage {
                return constantHeight + smallerMarginTop
            }
            
            return constantHeight + largerMarginTop
        }
        
        let attributedString = NSAttributedString(styledText: StyledText(
            text: body,
            style: .chatBody
        ))

        let size = attributedString.boundingRect(
            with: CGSize(width: 300, height: CGFloat(Int.max)),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        
        if isRelatedToPreviousMessage {
            return size.height + smallerMarginTop + 20
        }
        
        return size.height + largerMarginTop + 20
    }
    
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
                if message.type.isVideoOrImageType {
                    contentContainer.layoutMargins = UIEdgeInsets.zero
                } else {
                    contentContainer.layoutMargins = UIEdgeInsets(horizontalInset: 10, verticalInset: 10)
                }
                
                if message.isRelatedToPreviousMessage {
                    spacingContainer.layoutMargins = UIEdgeInsets(
                        top: message.smallerMarginTop,
                        left: 20,
                        bottom: 0,
                        right: 20
                    )
                } else {
                    spacingContainer.layoutMargins = UIEdgeInsets(
                        top: 20,
                        left: message.largerMarginTop,
                        bottom: 0,
                        right: 20
                    )
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
            case .image(_), .video(_):
                bubble.backgroundColor = .transparent
            default:
                bubble.backgroundColor = message.fromMyself ? .primaryTintColor : .secondaryBackground
            }
                        
            switch message.type {
            case let .image(url):                
                let imageViewContainer = UIView()
                imageViewContainer.alpha = 0
                
                let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFill
                
                imageView.kf.setImage(with: url) { result in
                    switch result {
                    case let .success(imageResult):
                        let width = imageResult.image.size.width
                        let height = imageResult.image.size.height
                        
                        if width > height {
                            imageViewContainer.snp.makeConstraints { make in
                                make.width.equalTo(300)
                            }
                        } else {
                            imageViewContainer.snp.makeConstraints { make in
                                make.width.equalTo(150)
                            }
                        }
                        
                        bag += Signal(after: 0).animated(
                            style: AnimationStyle.easeOut(duration: 0.25)
                        ) { _ in
                            imageViewContainer.alpha = 1
                        }
                        case .failure(_):
                        break
                    }
                    
                }
                
                imageViewContainer.addSubview(imageView)
                
                imageView.snp.makeConstraints { make in
                    make.height.equalToSuperview()
                    make.width.equalToSuperview()
                }
                
                imageViewContainer.snp.makeConstraints { make in
                    make.height.equalTo(200)
                }
                
                contentContainer.addArrangedSubview(imageViewContainer)
                
                bag += {
                    imageViewContainer.removeFromSuperview()
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
            
            UIView.setAnimationsEnabled(true)

            return bag
        })
    }
}
