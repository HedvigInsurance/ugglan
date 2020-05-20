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
import UIKit

extension ApolloClient {
    static var isShowingNetworkErrorMessage = false
    static var retryQueue: [(DispatchQueue, () -> Void)] = []

    func showNetworkErrorMessage(queue: DispatchQueue, onRetry: @escaping () -> Void) {
        ApolloClient.retryQueue.append((queue, onRetry))

        if ApolloClient.isShowingNetworkErrorMessage {
            return
        }

        ApolloClient.isShowingNetworkErrorMessage = true

        let alert = Alert<Bool>(
            title: L10n.networkErrorAlertTitle,
            message: L10n.networkErrorAlertMessage,
            actions:
            Alert.Action(title: L10n.networkErrorAlertTryAgainAction) { true },
            Alert.Action(title: L10n.networkErrorAlertCancelAction) { false }
        )

        DispatchQueue.main.async {
            var window: UIWindow? = UIWindow()
            window!.makeKeyAndVisible()
            window!.backgroundColor = UIColor.clear

            let viewController = UIViewController()
            viewController.view.backgroundColor = UIColor.clear
            window!.rootViewController = viewController

            let bag = DisposeBag()

            bag += viewController.present(alert).onValue { shouldRetry in
                if shouldRetry {
                    ApolloClient.retryQueue.forEach { queue, retry in
                        queue.async {
                            retry()
                        }
                    }
                }

                ApolloClient.retryQueue = []
                ApolloClient.isShowingNetworkErrorMessage = false
                bag.dispose()
                window = nil
            }
        }
    }
}
