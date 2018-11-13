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

private let messageViewReuseIdentifier = "MessageView"

class ListView: UITableView, View, UITableViewDataSource, UITableViewDelegate {
    var messages: [Message]? {
        didSet(oldValue) {
            messages = messages?.reversed()

            if messages == nil || oldValue == nil {
                return
            }

            if messages!.count - oldValue!.count == 1 {
                animateInsertion()
                scrollToBottom()
            }
        }
    }

    var keyboardHeight: CGFloat = 0.0
    var navigationBarHeight: CGFloat = 0.0
    let extraContentInsetPadding: CGFloat = 10

    override init(frame: CGRect = .zero, style: UITableView.Style = .plain) {
        super.init(frame: frame, style: style)
        setup()
        self.style()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        keyboardDismissMode = .interactive
        dataSource = self
        delegate = self
        separatorStyle = .none
        allowsSelection = false
        estimatedRowHeight = 10
        register(MessageView.self, forCellReuseIdentifier: messageViewReuseIdentifier)
        contentInset = .zero
        contentInsetAdjustmentBehavior = .never

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        DispatchQueue.main.async(execute: { () -> Void in
            self.reloadData()
        })
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            setContentInsetsFor(keyboardHeight: keyboardHeight)
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            setContentInsetsFor(keyboardHeight: keyboardHeight)
        }
    }

    func setContentInsetsFor(keyboardHeight: CGFloat) {
        if contentOffset.y == 0 {
            setContentOffset(CGPoint(x: 0, y: keyboardHeight), animated: true)
        }

        self.keyboardHeight = keyboardHeight
        contentInset = UIEdgeInsets(
            top: keyboardHeight + extraContentInsetPadding,
            left: 0,
            bottom: navigationBarHeight,
            right: 0
        )
    }

    func style() {
        transform = CGAffineTransform(rotationAngle: (-.pi))
    }

    func update() {}

    func animateInsertion() {
        let firstIndexPath = IndexPath(item: 0, section: 0)
        let visibleIndexPaths = indexPathsForVisibleRows!.filter { $0.item != 0 }

        beginUpdates()

        reloadRows(at: visibleIndexPaths, with: .none)
        insertRows(at: [firstIndexPath], with: .top)

        endUpdates()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pin.all()

        scrollIndicatorInsets = UIEdgeInsets(
            top: keyboardHeight,
            left: 0,
            bottom: navigationBarHeight,
            right: frame.width - 9
        )
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: messageViewReuseIdentifier,
            for: indexPath
        ) as? MessageView

        if cell == nil {
            return UITableViewCell()
        }

        if indexPath.item + 1 != messages?.count {
            if let nextMessage = messages?[indexPath.item + 1] {
                cell!.nextMessage = nextMessage
            } else {
                cell!.nextMessage = nil
            }
        } else {
            cell!.nextMessage = nil
        }

        if indexPath.item != 0 {
            if let previousMessage = messages?[indexPath.item - 1] {
                cell!.previousMessage = previousMessage
            } else {
                cell!.previousMessage = nil
            }
        } else {
            cell!.previousMessage = nil
        }

        cell!.message = messages?[indexPath.item]

        cell!.update()
        cell!.style()

        return cell!
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if let messages = self.messages {
            return messages.count
        }

        return 0
    }

    func scrollToBottom() {
        scrollToRow(at: IndexPath(item: 0, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
    }
}
