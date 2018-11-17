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
    var sendingIndicator: SendingIndicator?

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

        addSendingIndicator()
    }

    func style() {
        let fontSize: CGFloat = 15

        if let fromMyself = message?.header.fromMyself {
            if fromMyself {
                messageBubble.backgroundColor = HedvigColors.purple
                messageLabel.textColor = HedvigColors.white
                messageLabel.font = HedvigFonts.circularStdBook?.withSize(fontSize)
            } else {
                messageBubble.backgroundColor = HedvigColors.offWhite.darkened(amount: 0.01)
                messageLabel.textColor = HedvigColors.black
                messageLabel.font = HedvigFonts.merriweather?.withSize(fontSize)
            }
        }
    }

    func update() {
        messageLabel.text = message?.body.text
        layout()
        style()
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        contentView.pin.width(size.width)

        layout()

        let sendingIndicatorHeight = sendingIndicator?.frame.height ?? 0
        let height = messageBubble.frame.maxY + sendingIndicatorHeight

        return CGSize(width: contentView.frame.width, height: height)
    }

    func layout() {
        messageLabel.pin.sizeToFit(.width)
            .width(messageLabel.intrinsicContentSize.width)
            .maxWidth(200)

        let messageBubblePadding = PEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        messageBubble.pin.wrapContent(padding: messageBubblePadding)

        if nextMessage?.header.fromMyself == message?.header.fromMyself {
            messageBubble.pin.top(2)
        } else {
            messageBubble.pin.top(10)
        }

        if let fromMyself = message?.header.fromMyself {
            if fromMyself {
                messageBubble.pin.right(10)
            } else {
                messageBubble.pin.left(10)
            }
        }

        setMessageBubbleRadius()

        if sendingIndicator != nil {
            sendingIndicator!.pin.width(100%)
            sendingIndicator!.pin.bottom(0)
        }
    }

    func setMessageBubbleRadius() {
        let hasOwnPreviousMessage = previousMessage?.header.fromMyself == message?.header.fromMyself
        let hasOwnNextMessage = nextMessage?.header.fromMyself == message?.header.fromMyself
        let fromMyself = message?.header.fromMyself ?? false

        let majorPadding: CGFloat = 21
        let minorPadding: CGFloat = 5

        if hasOwnPreviousMessage {
            if hasOwnNextMessage {
                if fromMyself {
                    messageBubble.applyRadiusMaskFor(
                        topLeft: majorPadding,
                        bottomLeft: majorPadding,
                        bottomRight: minorPadding,
                        topRight: minorPadding
                    )
                } else {
                    messageBubble.applyRadiusMaskFor(
                        topLeft: minorPadding,
                        bottomLeft: minorPadding,
                        bottomRight: majorPadding,
                        topRight: majorPadding
                    )
                }
            } else {
                if fromMyself {
                    messageBubble.applyRadiusMaskFor(
                        topLeft: majorPadding,
                        bottomLeft: majorPadding,
                        bottomRight: minorPadding,
                        topRight: majorPadding
                    )
                } else {
                    messageBubble.applyRadiusMaskFor(
                        topLeft: majorPadding,
                        bottomLeft: minorPadding,
                        bottomRight: majorPadding,
                        topRight: majorPadding
                    )
                }
            }
        } else {
            if hasOwnNextMessage {
                if fromMyself {
                    messageBubble.applyRadiusMaskFor(
                        topLeft: majorPadding,
                        bottomLeft: majorPadding,
                        bottomRight: majorPadding,
                        topRight: minorPadding
                    )
                } else {
                    messageBubble.applyRadiusMaskFor(
                        topLeft: minorPadding,
                        bottomLeft: majorPadding,
                        bottomRight: majorPadding,
                        topRight: majorPadding
                    )
                }
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

    func addSendingIndicator() {
        if message?.isSending == true {
            sendingIndicator = SendingIndicator()
            addSubview(sendingIndicator!)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
}
