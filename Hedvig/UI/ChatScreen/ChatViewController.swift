//
//  ChatViewController.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-07.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import Tempura
import Katana

class ChatViewController: ViewControllerWithLocalState<ChatView> {
    let inputFieldView = InputFieldView()
    let wordmarkIocn = Icon(frame: .zero, iconName: "Wordmark", iconWidth: 90)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.topItem?.titleView = wordmarkIocn
        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Fortsätt", style: UIBarButtonItem.Style.plain, target: nil, action: nil)
        ]
        
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    override var inputAccessoryView: UIView? {
        return inputFieldView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        becomeFirstResponder()
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}
