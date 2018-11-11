//
//  SendButton.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-11.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import Tempura

class SendButton: UIButton, View {
    let arrowUpIcon = Icon(frame: .zero, iconName: "ArrowUp", iconWidth: 10)
    override var isEnabled: Bool {
        didSet {
            update()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        style()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.addSubview(arrowUpIcon)
    }
    
    func style() {
        self.backgroundColor = HedvigColors.purple
        self.layer.cornerRadius = 15
    }
    
    func update() {
        UIView.animate(withDuration: 0.25) {
            if self.isEnabled {
                self.backgroundColor = HedvigColors.purple
            } else {
                self.backgroundColor = HedvigColors.darkGray
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.pin.width(30)
        self.pin.height(30)
        arrowUpIcon.pin.center()
    }
}
