//
//  WebOnboarding.swift
//  test
//
//  Created by Sam Pettersson on 2020-03-19.
//

import Foundation
import Presentation
import UIKit
import Flow
import WebKit
import Apollo

struct WebOnboarding {}

extension WebOnboarding: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        let bag = DisposeBag()
        
        let settingsButton = UIBarButtonItem()
        settingsButton.image = Asset.menuIcon.image
        settingsButton.tintColor = .navigationItemMutedTintColor

        viewController.navigationItem.leftBarButtonItem = settingsButton

        bag += settingsButton.onValue { _ in
            viewController.present(
                About(state: .onboarding).withCloseButton,
                style: .modally(
                    presentationStyle: .formSheet,
                    transitionStyle: nil,
                    capturesStatusBarAppearance: false
                ),
                options: [.allowSwipeDismissAlways, .defaults]
            )
        }

        let restartButton = UIBarButtonItem()
        restartButton.image = Asset.restart.image
        restartButton.tintColor = .navigationItemMutedTintColor

        viewController.navigationItem.rightBarButtonItem = restartButton

        let titleHedvigLogo = UIImageView()
        titleHedvigLogo.image = Asset.wordmark.image
        titleHedvigLogo.contentMode = .scaleAspectFit

        viewController.navigationItem.titleView = titleHedvigLogo

        titleHedvigLogo.snp.makeConstraints { make in
            make.width.equalTo(80)
        }
        
        ApplicationState.preserveState(.onboardingChat)
        
        let webView = WKWebView(frame: .zero)
        webView.backgroundColor = .primaryBackground
        
        viewController.view = webView
        
        bag += webView.didReceiveAuthenticationChallenge.set { (_, _) -> (URLSession.AuthChallengeDisposition, URLCredential?) in
            let credentials = URLCredential.init(user: "hedvig", password: "hedvig1234", persistence: .forSession)
            return (.useCredential, credentials)
        }
        
        bag += webView.decidePolicyForNavigationAction.set { _, navigationAction in
            guard let url = navigationAction.request.url else { return .allow }
            let urlString = String(describing: url)

            if urlString.contains("connect-payment") {
                viewController.present(PostOnboarding(), style: .defaultOrModal, options: [])
                return .cancel
            }

            return .allow
        }
        
        func loadWebOnboarding() {
            guard let token = ApolloClient.retreiveToken() else {
                return
            }
                        
            func loadStaging() {
                guard let url = URL(string: "https://www.dev.hedvigit.com/new-member?variation=ios&locale=\(Localization.Locale.currentLocale.code)#token=\(token.token)") else {
                    return
                }
                
                webView.load(URLRequest(url: url))
            }
            
            switch ApplicationState.getTargetEnvironment() {
            case .production:
                guard let url = URL(string: "https://www.hedvig.com/new-member?variation=ios&locale=\(Localization.Locale.currentLocale.code)#token=\(token.token)") else {
                    return
                }
                webView.load(URLRequest(url: url))
            case .staging:
                loadStaging()
            case .custom(endpointURL: _, wsEndpointURL: _, assetsEndpointURL: _):
                loadStaging()
            }
            
        }
        
        bag += restartButton.onValue { _ in
           let alert = Alert(
               title: String(key: .CHAT_RESTART_ALERT_TITLE),
               message: String(key: .CHAT_RESTART_ALERT_MESSAGE),
               actions: [
                   Alert.Action(
                       title: String(key: .CHAT_RESTART_ALERT_CONFIRM),
                       action: {
                           loadWebOnboarding()
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
        
        loadWebOnboarding()
        
        return (viewController, bag)
    }
}

