//
//  WebOnboarding.swift
//  test
//
//  Created by Sam Pettersson on 2020-03-19.
//

import Apollo
import Flow
import Foundation
import Presentation
import UIKit
import WebKit

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
            let credentials = URLCredential(user: "hedvig", password: "hedvig1234", persistence: .forSession)
            return (.useCredential, credentials)
        }
        
        bag += webView.signal(for: \.url).onValue { url in
           let urlString = String(describing: url)

           if urlString.contains("connect-payment") {
               viewController.present(PostOnboarding(), style: .defaultOrModal, options: [])
           }
        }

        func loadWebOnboarding() {
            guard let token = ApolloClient.retreiveToken() else {
                return
            }
            
            let tokenString = token.token.replacingOccurrences(of: "=", with: "%3D")
            
            var localePath: String {
                switch Localization.Locale.currentLocale {
                case .en_NO:
                    return "no-en/"
                case .nb_NO:
                    return "no/"
                default:
                    return ""
                }
            }

            func loadStaging() {
                guard let url = URL(string: "https://www.dev.hedvigit.com/\(localePath)new-member?variation=ios#token=\(tokenString)") else {
                    return
                }

                webView.load(URLRequest(url: url))
            }

            switch ApplicationState.getTargetEnvironment() {
            case .production:
                guard let url = URL(string: "https://www.hedvig.com/\(localePath)new-member?variation=ios#token=\(token.token)") else {
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
