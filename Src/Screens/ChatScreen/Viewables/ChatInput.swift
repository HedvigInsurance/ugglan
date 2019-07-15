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
    let client: ApolloClient
    let currentGlobalIdSignal: ReadSignal<GraphQLID?>
    
    init(currentGlobalIdSignal: ReadSignal<GraphQLID?>, client: ApolloClient = ApolloContainer.shared.client) {
        self.currentGlobalIdSignal = currentGlobalIdSignal
        self.client = client
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
        
        let effect = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: effect)
        backgroundView.addSubview(effectView)

        effectView.snp.makeConstraints { make in
            make.width.height.leading.trailing.equalToSuperview()
        }
        
        let containerView = UIStackView()
        backgroundView.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        let textField = TextField(value: "Skriv här...", placeholder: "Bla bla")
        bag += containerView.addArranged(textField.wrappedIn(UIStackView())) { stackView in
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.layoutMargins = UIEdgeInsets(horizontalInset: 20, verticalInset: 20)
        }
        
        bag += textField.shouldReturn.set { (value, _) -> Bool in
            if let currentGlobalId = self.currentGlobalIdSignal.value {
                bag += self.client.perform(mutation: SendChatTextResponseMutation(globalId: currentGlobalId, text: value))
            }
            
            return false
        }
        
        return (backgroundView, bag)
    }
}
