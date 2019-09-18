//
//  OnboardingChat.swift
//  ugglan
//
//  Created by Gustaf Gunér on 2019-05-22.
//  Hedvig
//

import Apollo
import Flow
import Form
import Presentation
import UIKit

struct OnboardingChat {
    let client: ApolloClient

    init(client: ApolloClient = ApolloContainer.shared.client) {
        self.client = client
    }
}

extension OnboardingChat: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        ApplicationState.preserveState(.onboardingChat)

        let chat = Chat()
        let (viewController, future) = chat.materialize()
        viewController.navigationItem.hidesBackButton = true

        let settingsButton = UIBarButtonItem()
        settingsButton.image = Asset.menuIcon.image
        settingsButton.tintColor = .navigationItemMutedTintColor

        viewController.navigationItem.leftBarButtonItem = settingsButton

        bag += settingsButton.onValue({ _ in
            viewController.present(
                About(state: .onboarding).withCloseButton,
                style: .modally(presentationStyle: .formSheet, transitionStyle: nil, capturesStatusBarAppearance: nil),
                options: [.allowSwipeDismissAlways, .defaults]
            )
        })

        let restartButton = UIBarButtonItem()
        restartButton.image = Asset.restart.image
        restartButton.tintColor = .navigationItemMutedTintColor

        bag += restartButton.onValue { _ in
            let alert = Alert(
                title: String(key: .CHAT_RESTART_ALERT_TITLE),
                message: String(key: .CHAT_RESTART_ALERT_MESSAGE),
                actions: [
                    Alert.Action(
                        title: String(key: .CHAT_RESTART_ALERT_CONFIRM),
                        action: {
                            chat.reloadChatCallbacker.callAll()
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

        bag += future.disposable

        return (viewController, bag)
    }
}
