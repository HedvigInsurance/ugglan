//
//  ReferralsNotification.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-06-04.
//

import Flow
import Foundation
import Presentation
import UIKit

enum ReferralsNotificationResult {
    case cancel, openReferrals
}

struct ReferralsNotification {
    let incentive: Int
    let name: String
}

extension Notification.Name {
    static let shouldOpenReferrals = Notification.Name("shouldOpenReferrals")
}

extension ReferralsNotification: Presentable {
    func materialize() -> (UIViewController, Future<ReferralsNotificationResult>) {
        let bag = DisposeBag()
        let viewController = LightContentViewController()

        let view = UIView()
        view.backgroundColor = .primaryBackground

        viewController.view = view

        let openReferralsButton = Button(
            title: String(key: .REFERRAL_SUCCESS_BTN_CTA),
            type: .standard(backgroundColor: .purple, textColor: .white)
        )

        let closeButton = Button(
            title: String(key: .REFERRAL_SUCCESS_BTN_CLOSE),
            type: .pillSemiTransparent(backgroundColor: .blackPurple, textColor: .white)
        )

        let content = ImageTextAction<ReferralsNotificationResult>(
            image: .init(image: Asset.inviteSuccess.image),
            title: String(key: .REFERRAL_SUCCESS_HEADLINE(user: name)),
            body: String(key: .REFERRAL_SUCCESS_BODY(referralValue: String(incentive))),
            actions: [
                (.openReferrals, openReferralsButton),
                (.cancel, closeButton),
            ],
            showLogo: true
        )

        bag += view.didMoveToWindowSignal.onValue { _ in
            UIApplication.shared.keyWindow?.endEditing(true)
        }

        return (viewController, Future { completion in
            bag += view.add(content) { view in
                view.snp.makeConstraints { make in
                    make.top.bottom.trailing.leading.equalToSuperview()
                }
            }.onValue { result in
                completion(.success(result))
            }

            return DelayedDisposer(bag, delay: 2)
        })
    }
}
