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
        
        let navigationItemTintColor = UIColor(dynamic: { trait -> UIColor in
            trait.userInterfaceStyle == .dark ? .white : .darkGray
        })
        
        let settingsButton = UIBarButtonItem()
        settingsButton.image = Asset.menuIcon.image
        settingsButton.tintColor = navigationItemTintColor
        
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
        restartButton.tintColor = navigationItemTintColor

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
