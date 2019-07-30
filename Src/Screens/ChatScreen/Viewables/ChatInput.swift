//
//  ChatInput.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-07-12.
//

import Foundation
import Flow
import UIKit
import Apollo

struct ChatInput {
    let currentGlobalIdSignal: ReadSignal<GraphQLID?>
    
    init(currentGlobalIdSignal: ReadSignal<GraphQLID?>) {
        self.currentGlobalIdSignal = currentGlobalIdSignal
    }
}

class ViewWithFixedIntrinsicSize: UIView {
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 300, height: 200)
    }
}

extension ChatInput: Viewable {
    func materialize(events: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()
        
        let backgroundView = ViewWithFixedIntrinsicSize()
        backgroundView.autoresizingMask = .flexibleHeight
        backgroundView.backgroundColor = UIColor.offWhite.withAlphaComponent(0.8)
        
        let effect = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: effect)
        backgroundView.addSubview(effectView)

        effectView.snp.makeConstraints { make in
            make.width.height.leading.trailing.equalToSuperview()
        }
        
        let topBorderView = UIView()
        topBorderView.backgroundColor = .lightGray
        backgroundView.addSubview(topBorderView)
        
        topBorderView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(1 / UIScreen.main.scale)
        }
        
        let containerView = UIStackView()
        backgroundView.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        let textField = ChatTextView(currentGlobalIdSignal: currentGlobalIdSignal)
        bag += containerView.addArranged(textField.wrappedIn(UIStackView())) { stackView in
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.layoutMargins = UIEdgeInsets(horizontalInset: 20, verticalInset: 20)
        }
        
        return (backgroundView, bag)
    }
}
