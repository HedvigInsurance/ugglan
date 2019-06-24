//
//  ReferralsInvitation.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-06-10.
//

import Flow
import Foundation
import Presentation
import UIKit
import Apollo

enum ReferralsReceiverConsentResult {
    case accept, decline
}

struct ReferralsReceiverConsent {
    let referralCode: String
    let client: ApolloClient
    
    init(referralCode: String, client: ApolloClient = ApolloContainer.shared.client) {
        self.referralCode = referralCode
        self.client = client
    }
}

extension ReferralsReceiverConsent: Presentable {
    func materialize() -> (UIViewController, Future<ReferralsReceiverConsentResult>) {
        let bag = DisposeBag()
        let viewController = UIViewController()

        let view = UIView()
        view.backgroundColor = UIColor.offWhite

        let content = ReferralsReceiverConsentContent()

        bag += view.add(content) { view in
            view.snp.makeConstraints { make in
                make.top.bottom.trailing.leading.equalToSuperview()
            }
        }

        viewController.view = view

        return (viewController, Future { completion in
            bag += content.didTapDecline.onValue { _ in
                completion(.success(.decline))
            }
            
            bag += content
                .didTapAccept
                .mapLatestToFuture { self.client.perform(mutation: RedeemCodeMutation(code: self.referralCode)) }
                .onValue { _ in
                completion(.success(.accept))
            }

            return DelayedDisposer(bag, delay: 2)
        })
    }
}
