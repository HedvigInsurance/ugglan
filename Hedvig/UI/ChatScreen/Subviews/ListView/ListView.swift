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

private let messageViewReuseIdentifier = "MessageView"

class ListView: UITableView, View, UITableViewDataSource, UITableViewDelegate {
    var messages: [Message]? {
        didSet {
            self.messages = self.messages?.reversed()
            self.update()
        }
    }
    var keyboardHeight: CGFloat = 0.0
    var navigationBarHeight: CGFloat = 0.0
    let extraContentInsetPadding: CGFloat = 10
    
    override init(frame: CGRect = .zero, style: UITableView.Style = .plain) {
        super.init(frame: frame, style: style)
        self.setup()
        self.style()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.keyboardDismissMode = .interactive
        self.dataSource = self
        self.delegate = self
        self.separatorStyle = .none
        self.allowsSelection = false
        self.estimatedRowHeight = 10
        self.register(MessageView.self, forCellReuseIdentifier: messageViewReuseIdentifier)
        self.transform = CGAffineTransform(rotationAngle: (-.pi))
        self.contentInset = .zero
        self.contentInsetAdjustmentBehavior = .never
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide),
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
            self.setContentOffset(CGPoint(x: 0, y: keyboardHeight), animated: true)
        }
        
        self.keyboardHeight = keyboardHeight
        self.contentInset = UIEdgeInsets(
            top: keyboardHeight + extraContentInsetPadding,
            left: 0,
            bottom: navigationBarHeight,
            right: 0
        )
    }
    
    func style() {
        
    }
    
    func update() {
        self.reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.pin.all()
                
        self.scrollIndicatorInsets = UIEdgeInsets(
            top: keyboardHeight,
            left: 0,
            bottom: navigationBarHeight,
            right: self.frame.width - 9
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
        
        cell!.message = messages?[indexPath.item]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let messages = self.messages {
            return messages.count
        }
        
        return 0
    }
}
