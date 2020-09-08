//
//  ReferralsInvitation.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-06-10.
//

import Apollo
import Flow
import Foundation
import hCore
import hCoreUI
import hGraphQL
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
            title: L10n.referralStartscreenBtnCta,
            type: .standard(backgroundColor: .primaryButtonBackgroundColor, textColor: .primaryButtonTextColor)
        )

        let declineButton = Button(
            title: L10n.referralStartscreenBtnSkip,
            type: .pillSemiTransparent(backgroundColor: .lightGray, textColor: .offBlack)
        )

        let content = ImageTextAction<ReferralsReceiverConsentResult>(
            image: .init(image: Asset.inviteSuccess.image),
            title: L10n.referralStartscreenHeadline(10),
            body: L10n.referralSuccessBody(10),
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
                    self.client.perform(mutation: GraphQL.RedeemCodeMutation(code: self.referralCode))
                        .onValue { _ in
                            completion(.success(.accept))
                        }
                        .onError { _ in
                            let alert = Alert(
                                title: L10n.referralErrorMissingcodeHeadline,
                                message: L10n.referralErrorMissingcodeBody,
                                actions: [Alert.Action(title: L10n.referralErrorMissingcodeBtn) {}]
                            )

                            viewController.present(alert)
                        }
                case .decline:
                    completion(.success(.decline))
                }
            }

            return DelayedDisposer(bag, delay: 2)
        })
    }
}
