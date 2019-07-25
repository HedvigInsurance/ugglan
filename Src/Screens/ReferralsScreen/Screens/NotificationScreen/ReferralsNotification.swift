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
        view.backgroundColor = UIColor.darkPurple

        let progressed = ReferralsNotificationProgressed(incentive: incentive, name: name)

        bag += view.add(progressed) { view in
            view.snp.makeConstraints { make in
                make.top.bottom.trailing.leading.equalToSuperview()
            }
        }

        bag += view.didMoveToWindowSignal.onValue { _ in
            UIApplication.shared.keyWindow?.endEditing(true)
        }

        viewController.view = view

        return (viewController, Future { completion in
            bag += progressed.didTapCancel.onValue { _ in
                completion(.success(.cancel))
            }

            bag += progressed.didTapOpenReferrals.onValue { _ in
                completion(.success(.openReferrals))
            }

            return DelayedDisposer(bag, delay: 2)
        })
    }
}
