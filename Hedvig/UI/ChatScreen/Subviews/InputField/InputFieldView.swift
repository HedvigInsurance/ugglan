//
//  InputFieldView.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-07.
//  Copyright © 2018 Sam Pettersson. All rights reserved.
//

import Foundation
import UIKit
import Tempura
import PinLayout

let blurEffect = UIBlurEffect(style: .light)

class InputFieldView: UIView, View, UITextViewDelegate {
    var textView = UITextView()
    var blurView = UIVisualEffectView(effect: blurEffect)
    var safeAreaContainer = UIView()
    var heightConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.setup()
        self.style()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        safeAreaContainer.translatesAutoresizingMaskIntoConstraints = false
        
        safeAreaContainer.addSubview(textView)
        blurView.contentView.addSubview(safeAreaContainer)
        addSubview(blurView)
        
        safeAreaContainer.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        safeAreaContainer.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor).isActive = true
        safeAreaContainer.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor).isActive = true
        
        safeAreaContainer.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        heightConstraint = safeAreaContainer.heightAnchor.constraint(equalToConstant: 60)
        heightConstraint?.isActive = true
        
        textView.delegate = self
    }
    
    func style() {
        textView.backgroundColor = UIColor.white
        textView.layer.cornerRadius = 10
        textView.layer.borderColor = UIColor.black.cgColor
        textView.layer.borderWidth = 1
        textView.font = UIFont.systemFont(ofSize: 15)
    }
    
    func update() {
    }
    
    override func layoutSubviews() {
        textView.contentInset = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        textView.pin.width(95%)
        textView.pin.height(max(textView.contentSize.height, 40))
        textView.pin.top(10)
        textView.pin.left(2.5%)
    }
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.heightConstraint?.constant = max(textView.contentSize.height + 20, 60)
        self.setNeedsLayout()
    }
}
