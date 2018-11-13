//
//  MessageView.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-10.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import PinLayout
import Tempura
import UIKit
import UIViewRoundedCorners

class MessageView: UITableViewCell, View {
    let messageBubble = UIView()
    let messageLabel = CopyableLabel()

    var message: Message?
    var previousMessage: Message?
    var nextMessage: Message?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        self.style()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        transform = CGAffineTransform(rotationAngle: (-.pi))

        messageLabel.text = message?.body.text
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.numberOfLines = 0

        autoresizingMask = [.flexibleWidth, .flexibleHeight]

        messageBubble.addSubview(messageLabel)
        addSubview(messageBubble)
    }

    func style() {
        let fontSize: CGFloat = 15

        if let fromMyself = message?.fromMyself {
            if fromMyself {
                messageBubble.backgroundColor = HedvigColors.purple
                messageLabel.textColor = HedvigColors.white
                messageLabel.font = HedvigFonts.circularStdBook?.withSize(fontSize)
            } else {
                messageBubble.backgroundColor = HedvigColors.offWhite
                messageLabel.textColor = HedvigColors.black
                messageLabel.font = HedvigFonts.merriweather?.withSize(fontSize)
            }
        }
    }

    func update() {
        messageLabel.text = message?.body.text
        layout()
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        contentView.pin.width(size.width)

        layout()

        return CGSize(width: contentView.frame.width, height: messageBubble.frame.maxY)
    }

    func layout() {
        messageLabel.pin.sizeToFit(.width)
            .width(messageLabel.intrinsicContentSize.width)
            .maxWidth(200)

        let messageBubblePadding = PEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        messageBubble.pin.wrapContent(padding: messageBubblePadding)

        if nextMessage?.fromMyself == message?.fromMyself {
            messageBubble.pin.top(2)
        } else {
            messageBubble.pin.top(10)
        }

        if let fromMyself = message?.fromMyself {
            if fromMyself {
                messageBubble.pin.right(10)
            } else {
                messageBubble.pin.left(10)
            }
        }

        setMessageBubbleRadius()
    }

    func setMessageBubbleRadius() {
        let hasOwnPreviousMessage = previousMessage?.fromMyself == message?.fromMyself
        let hasOwnNextMessage = nextMessage?.fromMyself == message?.fromMyself

        let majorPadding: CGFloat = 21
        let minorPadding: CGFloat = 5

        if hasOwnPreviousMessage {
            if hasOwnNextMessage {
                messageBubble.applyRadiusMaskFor(
                    topLeft: majorPadding,
                    bottomLeft: majorPadding,
                    bottomRight: minorPadding,
                    topRight: minorPadding
                )
            } else {
                messageBubble.applyRadiusMaskFor(
                    topLeft: majorPadding,
                    bottomLeft: majorPadding,
                    bottomRight: minorPadding,
                    topRight: majorPadding
                )
            }
        } else {
            if hasOwnNextMessage {
                messageBubble.applyRadiusMaskFor(
                    topLeft: majorPadding,
                    bottomLeft: majorPadding,
                    bottomRight: majorPadding,
                    topRight: minorPadding
                )
            } else {
                messageBubble.applyRadiusMaskFor(
                    topLeft: majorPadding,
                    bottomLeft: majorPadding,
                    bottomRight: majorPadding,
                    topRight: majorPadding
                )
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
}
