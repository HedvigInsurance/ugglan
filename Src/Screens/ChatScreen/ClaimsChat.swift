//
//  ClaimsChat.swift
//  project
//
//  Created by Sam Pettersson on 2019-09-13.
//

import Apollo
import Flow
import Form
import Presentation
import UIKit

struct ClaimsChat {
    let client: ApolloClient

    init(client: ApolloClient = ApolloContainer.shared.client) {
        self.client = client
    }
}

extension ClaimsChat: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        let chat = Chat()
        let (viewController, future) = chat.materialize()
        viewController.navigationItem.hidesBackButton = true

        bag += client.perform(mutation: TriggerClaimChatMutation()).onValue({ _ in
            chat.chatState.fetch(cachePolicy: .fetchIgnoringCacheData)
        })

        let titleHedvigLogo = UIImageView()
        titleHedvigLogo.image = Asset.wordmark.image
        titleHedvigLogo.contentMode = .scaleAspectFit

        viewController.navigationItem.titleView = titleHedvigLogo

        titleHedvigLogo.snp.makeConstraints { make in
            make.width.equalTo(80)
        }

        bag += future.onValue({ _ in })

        return (viewController, bag)
    }
}
