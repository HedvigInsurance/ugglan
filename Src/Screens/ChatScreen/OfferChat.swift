//
//  OfferChat.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-08-05.
//

import Apollo
import Flow
import Foundation
import Presentation
import UIKit

struct OfferChat {
    @Inject var client: ApolloClient
}

extension OfferChat: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()
        let chat = Chat()
        let (viewController, future) = chat.materialize()

        let restartButton = UIBarButtonItem()
        restartButton.image = Asset.restart.image
        restartButton.tintColor = .darkGray

        bag += restartButton.onValue { _ in
            let alert = Alert(
                title: String(key: .CHAT_RESTART_ALERT_TITLE),
                message: String(key: .CHAT_RESTART_ALERT_MESSAGE),
                actions: [
                    Alert.Action(
                        title: String(key: .CHAT_RESTART_ALERT_CONFIRM),
                        action: {
                            UIView.transition(
                                with: UIApplication.shared.appDelegate.window,
                                duration: 0.25,
                                options: .transitionCrossDissolve,
                                animations: {
                                    ApplicationState.preserveState(.onboardingChat)
                                    UIApplication.shared.appDelegate.logout()
                                }, completion: nil
                            )
                        }
                    ),
                    Alert.Action(
                        title: String(key: .CHAT_RESTART_ALERT_CANCEL),
                        action: {}
                    ),
                ]
            )

            viewController.present(alert)
        }

        viewController.navigationItem.rightBarButtonItem = restartButton

        let titleHedvigLogo = UIImageView()
        titleHedvigLogo.image = Asset.wordmark.image
        titleHedvigLogo.contentMode = .scaleAspectFit

        viewController.navigationItem.titleView = titleHedvigLogo

        titleHedvigLogo.snp.makeConstraints { make in
            make.width.equalTo(80)
        }

        bag += client.perform(mutation: OfferClosedMutation()).onValue { _ in
            chat.chatState.fetch(cachePolicy: .fetchIgnoringCacheData) {
                chat.chatState.subscribe()
            }
        }

        return (viewController, Future { completion in
            bag += future.onResult { result in
                completion(result)
            }

            return bag
        })
    }
}
