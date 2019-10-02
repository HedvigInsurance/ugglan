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
    let client: ApolloClient

    init(client: ApolloClient = ApolloContainer.shared.client) {
        self.client = client
    }
}

extension OfferChat: Presentable {
    func materialize() -> (UIViewController, Future<Void>) {
        let bag = DisposeBag()
        let chat = Chat(shouldSubscribe: true)
        let (viewController, future) = chat.materialize()

        let restartButton = UIBarButtonItem()
        restartButton.image = Asset.restart.image
        restartButton.tintColor = .darkGray

        bag += restartButton.onValue { _ in
            ApplicationState.preserveState(.onboardingChat)
            UIApplication.shared.appDelegate.logout()
        }

        viewController.navigationItem.rightBarButtonItem = restartButton

        let titleHedvigLogo = UIImageView()
        titleHedvigLogo.image = Asset.wordmark.image
        titleHedvigLogo.contentMode = .scaleAspectFit

        viewController.navigationItem.titleView = titleHedvigLogo

        titleHedvigLogo.snp.makeConstraints { make in
            make.width.equalTo(80)
        }

        bag += client.perform(mutation: OfferClosedMutation()).onValue({ _ in
            chat.chatState.fetch(cachePolicy: .fetchIgnoringCacheData)
        })

        return (viewController, Future { completion in
            bag += future.onResult { result in
                completion(result)
            }

            return bag
        })
    }
}
