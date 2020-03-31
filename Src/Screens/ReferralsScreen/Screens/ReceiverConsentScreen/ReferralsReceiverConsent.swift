//
//  ReferralsInvitation.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-06-10.
//

import Apollo
import Flow
import Foundation
import Presentation
import UIKit

enum ReferralsReceiverConsentResult {
    case accept, decline
}

struct ReferralsReceiverConsent {
    let referralCode: String
    @Inject var client: ApolloClient

    init(referralCode: String) {
        self.referralCode = referralCode
    }
}

extension ReferralsReceiverConsent: Presentable {
    func materialize() -> (UIViewController, Future<ReferralsReceiverConsentResult>) {
        let bag = DisposeBag()
        let viewController = UIViewController()

        let view = UIView()
        view.backgroundColor = .secondaryBackground

        let acceptDiscountButton = Button(
            title: String(key: .REFERRAL_STARTSCREEN_BTN_CTA),
            type: .standard(backgroundColor: .primaryButtonBackgroundColor, textColor: .white)
        )

        let declineButton = Button(
            title: String(key: .REFERRAL_STARTSCREEN_BTN_SKIP),
            type: .pillSemiTransparent(backgroundColor: .lightGray, textColor: .offBlack)
        )

        let content = ImageTextAction<ReferralsReceiverConsentResult>(
            image: Asset.inviteSuccess.image,
            title: String(key: .REFERRAL_STARTSCREEN_HEADLINE(referralValue: "10")),
            body: String(key: .REFERRAL_STARTSCREEN_BODY(referralValue: "10")),
            actions: [
                (.accept, acceptDiscountButton),
                (.decline, declineButton),
            ],
            showLogo: true
        )

        bag += view.didMoveToWindowSignal.onValue { _ in
            UIApplication.shared.keyWindow?.endEditing(true)
        }

        viewController.view = view

        return (viewController, Future { completion in
            bag += view.add(content) { view in
                view.snp.makeConstraints { make in
                    make.top.bottom.trailing.leading.equalToSuperview()
                }
            }.onValue { result in
                switch result {
                case .accept:
                    self.client.perform(mutation: RedeemCodeMutation(code: self.referralCode))
                        .onValue { result in
                            if result.errors != nil {
                                let alert = Alert(
                                    title: String(key: .REFERRAL_ERROR_MISSINGCODE_HEADLINE),
                                    message: String(key: .REFERRAL_ERROR_MISSINGCODE_BODY),
                                    actions: [Alert.Action(title: String(key: .REFERRAL_ERROR_MISSINGCODE_BTN)) {}]
                                )

                                viewController.present(alert)
                            } else {
                                completion(.success(.accept))
                            }
                        }
                case .decline:
                    completion(.success(.decline))
                }
            }

            return DelayedDisposer(bag, delay: 2)
        })
    }
}
