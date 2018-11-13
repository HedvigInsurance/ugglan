//
//  CopyableLabel.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-11.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import UIKit

class CopyableLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)

        isUserInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(showMenu)))
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func showMenu(sender _: AnyObject?) {
        becomeFirstResponder()

        let menu = UIMenuController.shared

        if !menu.isMenuVisible {
            menu.setTargetRect(bounds, in: self)
            menu.setMenuVisible(true, animated: true)
        }
    }

    override func copy(_: Any?) {
        let board = UIPasteboard.general

        board.string = text

        let menu = UIMenuController.shared

        menu.setMenuVisible(false, animated: true)
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func canPerformAction(_ action: Selector, withSender _: Any?) -> Bool {
        return action == #selector(UIResponderStandardEditActions.copy)
    }
}
