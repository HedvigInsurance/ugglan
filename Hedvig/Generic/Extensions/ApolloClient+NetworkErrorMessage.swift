//
//  ApolloClient+NetworkErrorMessage.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-13.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Foundation
import Presentation

extension ApolloClient {
    static var isShowingNetworkErrorMessage = false
    static var retryQueue: [(() -> Void)] = []

    func showNetworkErrorMessage(onRetry: @escaping () -> Void) {
        ApolloClient.retryQueue.append(onRetry)

        if ApolloClient.isShowingNetworkErrorMessage {
            return
        }

        ApolloClient.isShowingNetworkErrorMessage = true

        let alert = Alert<Bool>(
            title: String.translation(.NETWORK_ERROR_ALERT_TITLE),
            message: String.translation(.NETWORK_ERROR_ALERT_MESSAGE),
            actions:
            Alert.Action(title: String.translation(.NETWORK_ERROR_ALERT_TRY_AGAIN_ACTION)) { true },
            Alert.Action(title: String.translation(.NETWORK_ERROR_ALERT_CANCEL_ACTION)) { false }
        )

        var window: UIWindow? = UIWindow()
        window!.makeKeyAndVisible()
        window!.backgroundColor = UIColor.clear

        let viewController = UIViewController()
        viewController.view.backgroundColor = UIColor.clear
        window!.rootViewController = viewController

        let bag = DisposeBag()

        bag += viewController.present(alert).onValue { shouldRetry in
            if shouldRetry {
                ApolloClient.retryQueue.forEach({ retry in
                    retry()
                })
            }

            ApolloClient.retryQueue = []
            ApolloClient.isShowingNetworkErrorMessage = false
            bag.dispose()
            window = nil
        }
    }
}
