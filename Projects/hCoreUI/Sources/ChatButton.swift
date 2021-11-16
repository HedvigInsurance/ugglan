import Flow
import Foundation
import UIKit
import hCore

public struct ChatButton {
    public static var openChatHandler: (_ viewController: UIViewController) -> Void = { _ in }
    public let presentingViewController: UIViewController
    public let allowsChatHint: Bool

    public init(
        presentingViewController: UIViewController,
        allowsChatHint: Bool = false
    ) {
        self.presentingViewController = presentingViewController
        self.allowsChatHint = allowsChatHint
    }
}

extension UIViewController {
    /// installs a chat button in the navigation bar to the right
    public func installChatButton(allowsChatHint: Bool = false) {
        let chatButton = ChatButton(presentingViewController: self, allowsChatHint: allowsChatHint)
        let item = UIBarButtonItem(viewable: chatButton)
        navigationItem.rightBarButtonItem = item
    }
}

extension ChatButton: Viewable {
    public func materialize(events _: ViewableEvents) -> (UIView, Disposable) {
        let bag = DisposeBag()

        let chatButtonView = UIControl()
        chatButtonView.backgroundColor = .brand(.primaryBackground())

        if allowsChatHint {
            let chatHintBag = bag.innerBag()
            chatHintBag += Signal(after: 4).filter(predicate: { chatButtonView.window != nil })
                .onFirstValue { _ in
                    chatHintBag += chatButtonView.present(
                        Tooltip(
                            id: "chatHint",
                            value: L10n.HomeTab.chatHintText,
                            sourceRect: chatButtonView.frame
                        )
                        .when(.onceEvery(timeInterval: .days(numberOfDays: 30)))
                    )
                    chatHintBag += chatButtonView.signal(for: .touchUpInside)
                        .onValue { chatHintBag.dispose() }
                }
        }

        bag += chatButtonView.signal(for: \.bounds).atOnce()
            .onValue { frame in chatButtonView.layer.cornerRadius = frame.height / 2 }

        bag += chatButtonView.signal(for: .touchUpInside).feedback(type: .impactLight)

        bag += chatButtonView.signal(for: .touchUpInside).onValue { _ in Self.openChatHandler(presentingViewController) }

        let chatIcon = UIImageView()
        chatIcon.isUserInteractionEnabled = false
        chatIcon.image = hCoreUIAssets.chat.image
        chatIcon.contentMode = .scaleAspectFit
        chatIcon.tintColor = .brand(.primaryText())

        bag += chatButtonView.signal(for: .touchDown)
            .animated(
                style: AnimationStyle.easeOut(duration: 0.25),
                animations: { _ in
                    chatButtonView.backgroundColor = UIColor.brand(.primaryBackground())
                        .darkened(amount: 0.1)
                }
            )

        bag += chatButtonView.delayedTouchCancel()
            .animated(style: AnimationStyle.easeOut(duration: 0.25)) { _ in
                chatButtonView.backgroundColor = .brand(.primaryBackground())
            }

        chatButtonView.addSubview(chatIcon)

        chatIcon.snp.makeConstraints { make in make.width.equalToSuperview().multipliedBy(0.6)
            make.height.equalToSuperview().multipliedBy(0.6)
            make.center.equalToSuperview()
        }

        chatButtonView.snp.makeConstraints { make in make.width.equalTo(40)
            make.height.equalTo(40)
        }

        return (chatButtonView, bag)
    }
}
