//
//  Message.swift
//  project
//
//  Created by Sam Pettersson on 2019-09-02.
//

import AVFoundation
import Flow
import Form
import Foundation
import Kingfisher
import UIKit

private let fiveMinutes: TimeInterval = 60 * 5

extension Message: Reusable {
    var largerMarginTop: CGFloat {
        20
    }

    var smallerMarginTop: CGFloat {
        2
    }

    var shouldShowTimeStamp: Bool {
        guard let previous = previous else {
            return timeStamp < Date().timeIntervalSince1970 - fiveMinutes
        }

        return previous.timeStamp < timeStamp - fiveMinutes
    }

    /// identifies if message belongs logically to the previous message
    var isRelatedToPreviousMessage: Bool {
        guard let previous = previous else {
            return false
        }

        if previous.timeStamp < timeStamp - fiveMinutes {
            return false
        }

        return previous.fromMyself == fromMyself
    }

    /// identifies if message belongs logically to the next message
    var isRelatedToNextMessage: Bool {
        guard let next = next else {
            if !fromMyself {
                return hasTypingIndicatorNext
            }

            return false
        }

        if next.timeStamp - fiveMinutes > timeStamp {
            return false
        }

        return next.fromMyself == fromMyself
    }

    /// calculates the total height that is required to render this message, including margins
    var totalHeight: CGFloat {
        let extraHeightForTimeStampLabel: CGFloat = {
            if !shouldShowTimeStamp {
                return 0
            }

            let timeStampText = NSAttributedString(styledText: StyledText(
                text: "11:33",
                style: TextStyle.chatTimeStamp.centerAligned
            ))

            let timeStampSize = timeStampText.boundingRect(
                with: CGSize(width: CGFloat(Int.max), height: CGFloat(Int.max)),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                context: nil
            )

            return timeStampSize.height + 5
        }()

        if type.isVideoOrImageType {
            let constantHeight: CGFloat = 200

            if isRelatedToPreviousMessage {
                return constantHeight + smallerMarginTop + extraHeightForTimeStampLabel
            }

            return constantHeight + largerMarginTop + extraHeightForTimeStampLabel
        }

        let attributedString = NSAttributedString(styledText: StyledText(
            text: body,
            style: .chatBody
        ))

        let size = attributedString.boundingRect(
            with: CGSize(width: 280, height: CGFloat(Int.max)),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )

        if isRelatedToPreviousMessage {
            return size.height + smallerMarginTop + 20 + extraHeightForTimeStampLabel
        }

        return size.height + largerMarginTop + 20 + extraHeightForTimeStampLabel
    }

    static func makeAndConfigure() -> (make: UIView, configure: (Message) -> Disposable) {
        let containerView = UIStackView()
        containerView.axis = .horizontal
        containerView.alignment = .fill
        containerView.spacing = 15

        let spacingContainer = UIStackView()
        spacingContainer.axis = .vertical
        spacingContainer.spacing = 5
        spacingContainer.insetsLayoutMarginsFromSafeArea = false
        spacingContainer.isLayoutMarginsRelativeArrangement = true
        containerView.addArrangedSubview(spacingContainer)

        let timeStampLabelContainer = UIStackView()
        timeStampLabelContainer.alignment = .center

        let timeStampLabel = UILabel(value: "", style: TextStyle.chatTimeStamp.centerAligned)
        timeStampLabelContainer.addArrangedSubview(timeStampLabel)

        spacingContainer.addArrangedSubview(timeStampLabelContainer)

        timeStampLabelContainer.snp.makeConstraints { make in
            make.width.equalToSuperview().inset(20)
        }

        let bubbleContainer = UIStackView()
        bubbleContainer.axis = .horizontal
        bubbleContainer.alignment = .fill
        bubbleContainer.spacing = 5
        spacingContainer.addArrangedSubview(bubbleContainer)

        let bubble = UIView()
        bubble.backgroundColor = .primaryTintColor

        bubble.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(300)
        }

        bubbleContainer.addArrangedSubview(bubble)

        let editbuttonStackContainer = UIStackView()
        editbuttonStackContainer.axis = .vertical
        editbuttonStackContainer.alignment = .top

        bubbleContainer.addArrangedSubview(editbuttonStackContainer)

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

            UIView.performWithoutAnimation {
                func handleTimeStamp() {
                    let shouldShowTimeStamp = message.shouldShowTimeStamp

                    timeStampLabelContainer.isHidden = !shouldShowTimeStamp

                    if !shouldShowTimeStamp { return }

                    let date = Date(timeIntervalSince1970: message.timeStamp)
                    let dateFormatter = DateFormatter()

                    if !Calendar.current.isDateInWeek(from: date) {
                        dateFormatter.dateFormat = "MMM d, yyyy - HH:mm"
                        timeStampLabel.text = dateFormatter.string(from: date)
                    } else if Calendar.current.isDateInToday(date) {
                        dateFormatter.dateFormat = "HH:mm"
                        timeStampLabel.text = dateFormatter.string(from: date)
                    } else {
                        dateFormatter.dateFormat = "EEEE HH:mm"
                        timeStampLabel.text = dateFormatter.string(from: date)
                    }
                }

                handleTimeStamp()

                editbuttonStackContainer.animationSafeIsHidden = !message.shouldShowEditButton

                bag += editButton.signal(for: .touchUpInside).onValue { _ in
                    message.onEditCallbacker.callAll()
                }

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

                bag += message.listSignal?.toVoid().animated(style: SpringAnimationStyle.lightBounce()) { _ in
                    editbuttonStackContainer.animationSafeIsHidden = !message.shouldShowEditButton
                    editbuttonStackContainer.alpha = message.shouldShowEditButton ? 1 : 0

                    applySpacing()
                    applyRounding()

                    spacingContainer.layoutSuperviewsIfNeeded()
                }

                spacingContainer.alignment = message.fromMyself ? .trailing : .leading

                let messageTextColor: UIColor = message.fromMyself ? .black : .primaryText

                switch message.type {
                case .image(_), .video:
                    bubble.backgroundColor = .transparent
                default:
                    bubble.backgroundColor = message.fromMyself ? .boxSecondaryBackground : .boxPrimaryBackground
                }

                switch message.type {
                case let .image(url):
                    let imageViewContainer = UIView()

                    let imageView = UIImageView()
                    imageView.contentMode = .scaleAspectFill

                    let processor = DownsamplingImageProcessor(
                        size: CGSize(
                            width: 300,
                            height: 200
                        )
                    )

                    imageView.kf.indicatorType = .custom(indicator: ImageActivityIndicator())
                    imageView.kf.setImage(
                        with: url,
                        options: [
                            .preloadAllAnimationData,
                            .processor(processor),
                            .backgroundDecode,
                            .transition(.fade(1)),
                        ]
                    ) { result in
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
                        case .failure:
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

                case let .gif(url):
                    bubble.backgroundColor = .transparent
                    let imageViewContainer = UIView()

                    let imageView = UIImageView()
                    imageView.contentMode = .scaleAspectFill
                    imageView.layer.cornerRadius = 5
                    imageView.backgroundColor = .clear
                    imageView.kf.indicatorType = .custom(indicator: ImageActivityIndicator())
                    imageView.kf.setImage(
                        with: url,
                        options: []
                    ) { result in
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

                        case .failure:
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
                    bag += contentContainer.addArranged(label) { _ in
                        let linkTapGestureRecognizer = UITapGestureRecognizer()
                        bag += contentContainer.install(linkTapGestureRecognizer)

                        bag += linkTapGestureRecognizer.signal(forState: .recognized).onValue { _ in
                            guard let url = url else { return }
                            message.onTapCallbacker.callAll(with: url)
                        }
                    }
                case let .video(url):
                    let imageViewContainer = UIView()

                    let imageView = UIImageView()
                    imageView.contentMode = .scaleAspectFill

                    let processor = DownsamplingImageProcessor(
                        size: CGSize(
                            width: 300,
                            height: 200
                        )
                    )

                    if let url = url {
                        let asset = AVURLAsset(url: url, options: nil)
                        imageView.kf.indicatorType = .custom(indicator: ImageActivityIndicator())
                        imageView.kf.setImage(
                            with: asset,
                            options: [
                                .preloadAllAnimationData,
                                .processor(processor),
                                .backgroundDecode,
                                .transition(.fade(1)),
                            ]
                        )
                    }

                    imageViewContainer.addSubview(imageView)

                    imageView.snp.makeConstraints { make in
                        make.height.equalToSuperview()
                        make.width.equalToSuperview()
                        make.width.equalTo(300)
                    }

                    imageViewContainer.snp.makeConstraints { make in
                        make.height.equalTo(200)
                    }

                    contentContainer.addArrangedSubview(imageViewContainer)

                    let videoTapGestureRecognizer = UITapGestureRecognizer()
                    bag += contentContainer.install(videoTapGestureRecognizer)

                    bag += videoTapGestureRecognizer.signal(forState: .recognized).onValue { _ in
                        guard let url = url else { return }
                        message.onTapCallbacker.callAll(with: url)
                    }

                    bag += {
                        imageViewContainer.removeFromSuperview()
                    }
                case .text:
                    if !message.fromMyself {
                        let label = MultilineLabel(
                            value: message.body,
                            style: TextStyle.bodyRegularRegularLeft
                        )
                        bag += contentContainer.addArranged(label)
                    } else {
                        let label = MultilineLabel(
                            value: message.body,
                            style: TextStyle.bodyRegularNegRegularNegLeft
                        )
                        bag += contentContainer.addArranged(label) { label in
                            label.textColor = .black
                        }
                    }
                    
                }

                if !message.type.isRichType {
                    bag += bubble.copySignal.onValue { _ in
                        UIPasteboard.general.value = message.body
                    }
                }

                bag += bubble.didLayoutSignal.onValue { _ in
                    applyRounding()
                }

                applySpacing()
            }

            return bag
        })
    }
}
