//
//  Onboarding.swift
//  test
//
//  Created by Sam Pettersson on 2020-01-29.
//

import Apollo
import Flow
import Form
import Presentation
import UIKit
import WebKit

struct Onboarding {
    @Inject var client: ApolloClient
}

extension Onboarding: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let bag = DisposeBag()

        ApplicationState.preserveState(.onboardingChat)
        
        let viewController = UIViewController()
        
        let containerView = UIView()
        viewController.view = containerView

        let imageView = UIImageView()
        imageView.image = Asset.orangeBackground.image
        imageView.contentMode = .scaleAspectFill
        containerView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        let webView = WKWebView()
        containerView.addSubview(webView)
        
        webView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        webView.backgroundColor = UIColor.transparent
        webView.isOpaque = false
        
        func createURLRequest() -> URLRequest {
            let username = "hedvig"
            let password = "hedvig1234"
            let loginString = String(format: "%@:%@", username, password)
            let loginData = loginString.data(using: String.Encoding.utf8)!
            let base64LoginString = loginData.base64EncodedString()

            var request = URLRequest(url: URL(string: "https://www.dev.hedvigit.com/new-member")!)
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
    
            return request
        }
        
        webView.load(createURLRequest())
        
        viewController.navigationItem.hidesBackButton = true
        
        let settingsButton = UIBarButtonItem()
        settingsButton.image = Asset.menuIcon.image
        settingsButton.tintColor = .navigationItemMutedTintColor

        viewController.navigationItem.leftBarButtonItem = settingsButton

        bag += settingsButton.onValue({ _ in
            viewController.present(
                About(state: .onboarding).withCloseButton,
                style: .modally(
                    presentationStyle: .formSheet,
                    transitionStyle: nil,
                    capturesStatusBarAppearance: true
                ),
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
                            
                        }
                    ),
                    Alert.Action(
                        title: String(key: .CHAT_RESTART_ALERT_CANCEL),
                        action: {}
                    ),
                ]
            )

            viewController.present(alert).onValue { _ in
                webView.load(createURLRequest())
            }
        }

        viewController.navigationItem.rightBarButtonItem = restartButton

        let titleHedvigLogo = UIImageView()
        titleHedvigLogo.image = Asset.wordmark.image
        titleHedvigLogo.contentMode = .scaleAspectFit

        viewController.navigationItem.titleView = titleHedvigLogo

        titleHedvigLogo.snp.makeConstraints { make in
            make.width.equalTo(80)
        }

        return (viewController, bag)
    }
}

