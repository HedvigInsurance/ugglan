//
//  MessageView.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-10.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import UIKit
import Tempura
import PinLayout

class MessageView: UITableViewCell, View {
    let messageBubble = UIView()
    let messageLabel = UILabel()
    
    var message: Message? {
        didSet {
            update()
            style()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
        self.style()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        messageLabel.text = message?.body.text
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.numberOfLines = 0
        
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
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
        
        messageBubble.pin.wrapContent(padding: 15).top(10)
        
        if let fromMyself = message?.fromMyself {
            if fromMyself {
                messageBubble.pin.right(10)
            } else {
                messageBubble.pin.left(10)
            }
        }
        
        messageBubble.layer.cornerRadius = 20
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
}
