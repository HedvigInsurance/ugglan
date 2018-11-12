//
//  KeyboardSpacer.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-11.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import Tempura
import UIKit
import PinLayout

class KeyboardSpacer: UIView, View {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        style()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
    }
    
    func style() {
        backgroundColor = HedvigColors.pink
    }
    
    func update() {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.pin.height(300)
        self.pin.width(100%)
    }
}
