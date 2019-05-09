//
//  ChatButton.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-05-09.
//

import Flow
import Foundation
import UIKit

struct ChatButton {
    let presentingViewController: UIViewController
}

extension UIViewController {
    /// installs a chat button in the navigation bar to the right
    func installChatButton() {
        let chatButton = ChatButton(presentingViewController: self)
        let item = UIBarButtonItem(viewable: chatButton)
        navigationItem.rightBarButtonItem = item
    }
}

extension ChatButton: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let chatButtonView = UIControl()
        chatButtonView.backgroundColor = .offLightGray
        chatButtonView.layer.cornerRadius = 20

        bag += chatButtonView.signal(for: .touchDown).animated(style: AnimationStyle.easeOut(duration: 0.25)) {
            chatButtonView.backgroundColor = UIColor.offLightGray.darkened(amount: 0.05)
        }

        bag += chatButtonView.signal(for: .touchUpInside).feedback(type: .impactLight)

        bag += merge(
            chatButtonView.signal(for: .touchUpInside).delay(by: 0.2),
            chatButtonView.signal(for: .touchUpOutside),
            chatButtonView.signal(for: .touchCancel)
        ).animated(style: AnimationStyle.easeOut(duration: 0.25)) {
            chatButtonView.backgroundColor = UIColor.offLightGray
        }

        bag += chatButtonView.signal(for: .touchUpInside).onValue { _ in
            dashboardOpenFreeTextChat(self.presentingViewController)
        }

        let chatIcon = UIImageView()
        chatIcon.image = Asset.chat.image
        chatIcon.contentMode = .scaleAspectFit

        chatButtonView.addSubview(chatIcon)

        chatIcon.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalToSuperview().multipliedBy(0.5)
            make.center.equalToSuperview()
        }

        chatButtonView.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.height.equalTo(40)
        }

        return (chatButtonView, bag)
    }
}
