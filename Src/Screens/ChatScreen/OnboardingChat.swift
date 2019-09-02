//
//  OnboardingChat.swift
//  ugglan
//
//  Created by Gustaf Gunér on 2019-05-22.
//  Hedvig
//

import Flow
import Form
import Presentation
import UIKit
import Apollo

struct OnboardingChat {
    enum Intent: String {
        case onboard, login
    }

    let intent: Intent
    let client: ApolloClient

    init(intent: Intent, client: ApolloClient = ApolloContainer.shared.client) {
        self.intent = intent
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

        let restartButton = UIBarButtonItem()
        restartButton.image = Asset.restart.image
        restartButton.tintColor = .darkGray

        bag += restartButton.onValue { _ in
            
            let alert = Alert.init(title: "Vill du starta om?", message: "All information du fyllt i kommer att försvinna.", actions: [
                Alert.Action.init(title: "OK", action: {
                    chat.reloadChatCallbacker.callAll()
                }),
                Alert.Action.init(title: "Avbryt", action: {
                    
                })
            ])
            
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
