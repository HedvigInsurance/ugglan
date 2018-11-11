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
        self.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: self.bounds.size.width - 10)
    }
    
    func style() {
        
    }
    
    func update() {
        self.reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.pin.all()
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
        // The UITableView will call the cell's sizeThatFit() method to compute the height.
        // WANRING: You must also set the UITableView.estimatedRowHeight for this to work.
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let messages = self.messages {
            return messages.count
        }
        
        return 0
    }
}
