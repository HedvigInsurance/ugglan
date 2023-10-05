import AVFoundation
import Flow
import Form
import Foundation
import Kingfisher
import SafariServices
import UIKit
import hAnalytics
import hCore
import hCoreUI

private let fiveMinutes: TimeInterval = 60 * 5

extension Message: Reusable {
    var largerMarginTop: CGFloat { 20 }

    var smallerMarginTop: CGFloat { 2 }

    var shouldShowTimeStamp: Bool {
        guard let previous = previous else { return timeStamp < Date().timeIntervalSince1970 - fiveMinutes }
        return previous.timeStamp < timeStamp - fiveMinutes
    }

    /// identifies if message belongs logically to the previous message
    var isRelatedToPreviousMessage: Bool {
        guard let previous = previous else { return false }

        if previous.timeStamp < timeStamp - fiveMinutes { return false }

        return previous.fromMyself == fromMyself
    }

    /// identifies if message belongs logically to the next message
    var isRelatedToNextMessage: Bool {
        guard let next = next else {
            if !fromMyself { return hasTypingIndicatorNext }

            return false
        }

        if next.timeStamp - fiveMinutes > timeStamp { return false }

        return next.fromMyself == fromMyself
    }

    /// calculates the total height that is required to render this message, including margins
    var totalHeight: CGFloat {
        let extraHeightForTimeStampLabel: CGFloat = {
            if !shouldShowTimeStamp { return 0 }

            let timeStampText = NSAttributedString(
                styledText: StyledText(
                    text: "11:33",
                    style: UIColor.brandNewStyle(.chatTimeStamp)
                )
            )

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
        if case let .crossSell(url) = type {
            let data = WebMetaDataProvider.shared.data(for: url!)?.title ?? ""
            let attributedString = NSAttributedString(
                styledText: StyledText(text: data, style: UIColor.brandNewStyle(.chatMessage))
            )
            let size = attributedString.boundingRect(
                with: CGSize(width: 267.77, height: CGFloat(Int.max)),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                context: nil
            )
            if isRelatedToPreviousMessage {
                return 350 + size.height + smallerMarginTop + extraHeightForTimeStampLabel
            }

            return 350 + size.height + largerMarginTop + extraHeightForTimeStampLabel
        }

        let attributedString = NSAttributedString(
            styledText: StyledText(text: body, style: UIColor.brandNewStyle(.chatMessage))
        )

        let size = attributedString.boundingRect(
            with: CGSize(width: 267.77, height: CGFloat(Int.max)),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )

        let extraPadding: CGFloat = {
            if hAnalyticsExperiment.useHedvigLettersFont {
                return 25
            }

            return 20
        }()

        if isRelatedToPreviousMessage {
            return size.height + smallerMarginTop + extraPadding + extraHeightForTimeStampLabel
        }

        return size.height + largerMarginTop + extraPadding + extraHeightForTimeStampLabel
    }

    static var bubbleColor: UIColor { UIColor(red: 0.904, green: 0.837, blue: 1, alpha: 1) }

    static var hedvigBubbleColor: UIColor {
        UIColor(base: UIColor.brandNew(.secondaryBackground()), elevated: UIColor.brandNew(.primaryBackground()))
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

        let timeStampLabel = UILabel(
            value: "",
            style: UIColor.brandNewStyle(.chatTimeStamp)
        )
        timeStampLabelContainer.addArrangedSubview(timeStampLabel)

        spacingContainer.addArrangedSubview(timeStampLabelContainer)
        timeStampLabelContainer.snp.makeConstraints { make in make.width.equalToSuperview().inset(20) }

        let bubbleContainer = UIStackView()
        bubbleContainer.axis = .horizontal
        bubbleContainer.alignment = .fill
        bubbleContainer.spacing = 5
        spacingContainer.addArrangedSubview(bubbleContainer)

        let bubble = UIView()
        bubble.layer.cornerRadius = 12
        bubble.snp.makeConstraints { make in make.width.lessThanOrEqualTo(300) }

        bubbleContainer.addArrangedSubview(bubble)

        let editButtonViewContainer = UIView()
        editButtonViewContainer.snp.makeConstraints { make in make.width.equalTo(20) }

        let editButton = UIControl()
        editButtonViewContainer.addSubview(editButton)
        editButton.backgroundColor = Self.bubbleColor
        editButton.snp.makeConstraints { make in make.width.height.equalTo(20) }
        editButton.layer.cornerRadius = 6

        let editButtonIcon = UIImageView(image: hCoreUIAssets.editIconFilled.image)
        editButtonIcon.tintColor = .black
        editButtonIcon.contentMode = .scaleAspectFit
        editButton.addSubview(editButtonIcon)

        editButtonIcon.snp.makeConstraints { make in make.height.width.equalToSuperview().multipliedBy(0.5)
            make.center.equalToSuperview()
        }

        let contentContainer = UIStackView()
        contentContainer.layoutMargins = UIEdgeInsets(horizontalInset: 10, verticalInset: 10)
        contentContainer.isLayoutMarginsRelativeArrangement = true
        contentContainer.insetsLayoutMarginsFromSafeArea = false

        bubble.addSubview(contentContainer)

        contentContainer.snp.makeConstraints { make in make.leading.trailing.top.bottom.equalToSuperview() }

        return (
            containerView,
            { message in
                let bag = DisposeBag()

                contentContainer.subviews.forEach { view in
                    view.removeFromSuperview()
                }
                timeStampLabel.textAlignment = message.fromMyself ? .right : .left

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

                    bag += editButton.signal(for: .touchUpInside)
                        .onValue { _ in message.onEditCallbacker.callAll() }

                    func applySpacing() {
                        if message.type.isVideoOrImageType {
                            contentContainer.layoutMargins = UIEdgeInsets.zero
                        } else if message.type.isCrossSell {
                            contentContainer.layoutMargins = UIEdgeInsets(
                                horizontalInset: 16,
                                verticalInset: 0
                            )
                        } else {
                            contentContainer.layoutMargins = UIEdgeInsets(
                                horizontalInset: 16,
                                verticalInset: message.shouldShowTimeStamp ? 10 : 0
                            )
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

                    func applyRounding() {
                        bubble.applyRadiusMaskFor(
                            topLeft: message.absoluteRadiusValue(
                                radius: message.topLeftRadius,
                                view: bubble
                            ),
                            bottomLeft: message.absoluteRadiusValue(
                                radius: message.bottomLeftRadius,
                                view: bubble
                            ),
                            bottomRight: message.absoluteRadiusValue(
                                radius: message.bottomRightRadius,
                                view: bubble
                            ),
                            topRight: message.absoluteRadiusValue(
                                radius: message.topRightRadius,
                                view: bubble
                            )
                        )
                    }

                    bag += message.listSignal?.toVoid()
                        .animated(style: SpringAnimationStyle.lightBounce()) { _ in
                            applySpacing()
                            spacingContainer.layoutSuperviewsIfNeeded()
                        }
                    timeStampLabelContainer.alignment = message.fromMyself ? .trailing : .leading
                    spacingContainer.alignment = message.fromMyself ? .trailing : .leading

                    let messageTextColor = UIColor.brandNew(.chatMessage)

                    switch message.type {
                    case .image, .video:
                        bubble.backgroundColor = .clear
                    default:
                        bubble.backgroundColor = UIColor.brandNew(.messageBackground(message.fromMyself))
                    }

                    switch message.type {
                    case let .image(url):
                        let imageViewContainer = UIView()

                        let imageView = UIImageView()
                        imageView.contentMode = .scaleAspectFill
                        imageView.layer.masksToBounds = true
                        imageView.layer.cornerRadius = 9

                        let processor = DownsamplingImageProcessor(
                            size: CGSize(width: 300, height: 200)
                        )

                        imageView.kf.indicatorType = .custom(
                            indicator: ImageActivityIndicator()
                        )
                        imageView.kf.setImage(
                            with: url,
                            options: [
                                .preloadAllAnimationData, .processor(processor),
                                .backgroundDecode, .transition(.fade(1)),
                            ]
                        )

                        bag += imageView.signal(for: \.image).atOnce().compactMap { $0 }
                            .onValue { image in let width = image.size.width
                                let height = image.size.height

                                if width > height {
                                    imageViewContainer.snp.remakeConstraints {
                                        make in make.height.equalTo(200)
                                        make.width.equalTo(300)
                                    }
                                } else {
                                    imageViewContainer.snp.remakeConstraints {
                                        make in make.height.equalTo(200)
                                        make.width.equalTo(150)
                                    }
                                }

                                UIView.performWithoutAnimation {
                                    imageViewContainer.layoutIfNeeded()
                                }
                            }

                        imageViewContainer.addSubview(imageView)

                        imageView.snp.makeConstraints { make in make.height.equalToSuperview()
                            make.width.equalToSuperview()
                        }

                        contentContainer.addArrangedSubview(imageViewContainer)
                    case let .gif(url):
                        bubble.backgroundColor = .clear
                        let imageViewContainer = UIView()

                        let imageView = UIImageView()
                        imageView.contentMode = .scaleAspectFill
                        imageView.layer.masksToBounds = true
                        imageView.layer.cornerRadius = 9
                        imageView.backgroundColor = .clear
                        imageView.kf.indicatorType = .custom(
                            indicator: ImageActivityIndicator()
                        )
                        imageView.kf.setImage(with: url, options: [])

                        bag += imageView.signal(for: \.image).atOnce().compactMap { $0 }
                            .onValue { image in let width = image.size.width
                                let height = image.size.height

                                if width > height {
                                    imageViewContainer.snp.remakeConstraints {
                                        make in make.height.equalTo(200)
                                        make.width.equalTo(300)
                                    }
                                } else {
                                    imageViewContainer.snp.remakeConstraints {
                                        make in make.height.equalTo(200)
                                        make.width.equalTo(150)
                                    }
                                }

                                UIView.performWithoutAnimation {
                                    imageViewContainer.layoutIfNeeded()
                                }
                            }

                        imageViewContainer.addSubview(imageView)
                        imageView.snp.makeConstraints { make in make.height.equalToSuperview()
                            make.width.equalToSuperview()
                        }

                        imageViewContainer.snp.makeConstraints { make in
                            make.height.equalTo(200)
                        }

                        contentContainer.addArrangedSubview(imageViewContainer)
                    case let .crossSell(url):
                        let crossSaleMainContainer = UIView()
                        let crossSaleContainer = UIView()
                        let loadingIndicator = UIActivityIndicatorView(style: .medium)
                        loadingIndicator.hidesWhenStopped = true
                        crossSaleMainContainer.addSubview(crossSaleContainer)
                        crossSaleContainer.snp.makeConstraints { make in
                            make.leading.trailing.top.bottom.equalToSuperview()
                        }
                        crossSaleMainContainer.addSubview(loadingIndicator)
                        loadingIndicator.snp.makeConstraints { make in
                            make.centerX.centerY.equalToSuperview()
                        }
                        crossSaleContainer.isUserInteractionEnabled = true
                        let imageView = UIImageView()
                        crossSaleContainer.addSubview(imageView)
                        imageView.snp.makeConstraints { make in
                            make.leading.equalToSuperview()
                            make.trailing.equalToSuperview()
                            make.top.equalToSuperview().offset(message.shouldShowTimeStamp ? 12 : 12)
                            make.width.equalTo(imageView.snp.height)
                        }

                        imageView.layer.cornerRadius = 20
                        imageView.clipsToBounds = true
                        //title //subtitle
                        let textStyle = UIColor.brandNewStyle(.chatMessage)
                            .colored(messageTextColor)

                        let text = L10n.chatFileDownload

                        let styledText = StyledText(text: text, style: textStyle)

                        let titleLabel = UILabel(styledText: styledText)
                        titleLabel.font = Fonts.fontFor(style: .standard)
                        titleLabel.text = ""
                        titleLabel.numberOfLines = 2
                        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
                        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

                        crossSaleContainer.addSubview(titleLabel)
                        titleLabel.snp.makeConstraints { make in
                            make.top.equalTo(imageView.snp.bottom).offset(10)
                            make.leading.equalToSuperview()
                            make.trailing.equalToSuperview()
                        }

                        //button
                        let button = UIButton(type: .custom)
                        button.setTitle(L10n.crossSellGetPrice)
                        button.backgroundColor = UIColor(hexString: "#EAFFCC")
                        button.tintColor = UIColor.black
                        button.setTitleColor(UIColor.black, for: .normal)
                        button.titleLabel?.textColor = UIColor.black
                        button.titleLabel?.font = Fonts.fontFor(style: .standardSmall)

                        button.contentEdgeInsets = .init(horizontalInset: 10, verticalInset: 6)
                        button.layer.cornerRadius = 12

                        bag += button.signal(for: .touchUpInside)
                            .onValue { _ in
                                if let url {
                                    UIApplication.shared.open(url)
                                }
                            }
                        crossSaleContainer.addSubview(button)
                        button.snp.makeConstraints { make in
                            make.leading.equalToSuperview()
                            make.top.equalTo(titleLabel.snp.bottom).offset(10)
                        }
                        contentContainer.addArrangedSubview(crossSaleMainContainer)
                        crossSaleContainer.snp.makeConstraints { make in
                            make.width.equalTo(300)
                        }

                        crossSaleContainer.alpha = 0

                        if let data = WebMetaDataProvider.shared.data(for: url!) {
                            crossSaleContainer.alpha = 1
                            titleLabel.text = data.title
                            imageView.image = data.image
                        } else {
                            loadingIndicator.startAnimating()
                            WebMetaDataProvider.shared.data(for: url!) { data in
                                if let data {
                                    UIView.animate(withDuration: 0.4) {
                                        crossSaleContainer.alpha = 1
                                        titleLabel.text = data.title
                                        imageView.image = data.image ?? hCoreUIAssets.hedvigBigLogo.image
                                    }
                                    let superview = containerView.superview?.superview?.superview
                                    if let superviewCell = superview as? UITableViewCell,
                                        let table = superviewCell.superview as? UITableView
                                    {
                                        table.beginUpdates()
                                        table.endUpdates()
                                    }
                                    loadingIndicator.stopAnimating()
                                }
                            }
                        }
                    case let .file(url):
                        let textStyle = UIColor.brandNewStyle(.chatMessage)
                            .colored(messageTextColor)

                        let text = L10n.chatFileDownload

                        let styledText = StyledText(text: text, style: textStyle)

                        let label = UILabel(styledText: styledText)
                        label.numberOfLines = 0
                        label.isUserInteractionEnabled = false

                        contentContainer.addArrangedSubview(label)

                        let linkTapGestureRecognizer = UITapGestureRecognizer()
                        bag += contentContainer.install(linkTapGestureRecognizer)

                        bag += linkTapGestureRecognizer.signal(forState: .recognized)
                            .onValue { _ in guard let url = url else { return }
                                label.viewController?
                                    .present(
                                        SFSafariViewController(url: url),
                                        animated: true
                                    )
                            }
                    case let .video(url):
                        let imageViewContainer = UIView()

                        let imageView = UIImageView()
                        imageView.contentMode = .scaleAspectFill
                        imageView.layer.masksToBounds = true
                        imageView.layer.cornerRadius = 9

                        let processor = DownsamplingImageProcessor(
                            size: CGSize(width: 300, height: 200)
                        )

                        if let url = url {
                            let asset = AVURLAsset(url: url)
                            imageView.kf.indicatorType = .custom(
                                indicator: ImageActivityIndicator()
                            )
                            imageView.kf.setImage(
                                with: asset,
                                options: [
                                    .preloadAllAnimationData, .processor(processor),
                                    .backgroundDecode, .transition(.fade(1)),
                                ]
                            )
                        }

                        imageViewContainer.addSubview(imageView)

                        imageView.snp.makeConstraints { make in make.height.equalToSuperview()
                            make.width.equalToSuperview()
                            make.width.equalTo(300)
                        }

                        imageViewContainer.snp.makeConstraints { make in
                            make.height.equalTo(200)
                        }

                        contentContainer.addArrangedSubview(imageViewContainer)

                        let videoTapGestureRecognizer = UITapGestureRecognizer()
                        bag += contentContainer.install(videoTapGestureRecognizer)

                        bag += videoTapGestureRecognizer.signal(forState: .recognized)
                            .onValue { _ in guard let url = url else { return }
                                imageView.viewController?
                                    .present(
                                        VideoPlayer(player: AVPlayer(url: url)),
                                        style: .modal,
                                        options: []
                                    )
                            }
                    case .text:
                        let textStyle = UIColor.brandNewStyle(.chatMessage)
                            .colored(messageTextColor)
                        let attributedString = NSMutableAttributedString(
                            text: message.body,
                            style: textStyle
                        )

                        message.body.links.forEach { linkRange in
                            attributedString.addAttributes(
                                [
                                    NSAttributedString.Key.underlineStyle:
                                        NSUnderlineStyle.single.rawValue,
                                    NSAttributedString.Key.underlineColor:
                                        messageTextColor,
                                ],
                                range: linkRange.range
                            )
                        }

                        let label = UILabel()
                        label.attributedText = attributedString
                        label.numberOfLines = 0

                        contentContainer.addArrangedSubview(label)

                        let linkTapGestureRecognizer = UITapGestureRecognizer()
                        bag += contentContainer.install(linkTapGestureRecognizer)

                        bag += linkTapGestureRecognizer.signal(forState: .recognized)
                            .onValue { _ in
                                let tappedLink = message.body.links.first {
                                    result -> Bool in
                                    linkTapGestureRecognizer.didTapRange(
                                        in: label,
                                        range: result.range
                                    )
                                }

                                if let url = tappedLink?.url,
                                    ["http", "https"].contains(url.scheme)
                                {
                                    label.viewController?
                                        .present(
                                            SFSafariViewController(
                                                url: url
                                            ),
                                            animated: true
                                        )
                                }
                            }
                    }

                    if !message.type.isRichType {
                        bag += bubble.copySignal.onValue { _ in
                            UIPasteboard.general.value = message.body
                        }
                    }

                    bag += bubble.didLayoutSignal.onValue { _ in applyRounding() }

                    applySpacing()
                }

                return bag
            }
        )
    }
}
