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

final class WebOnboardingWebView: WKWebView, UIScrollViewDelegate {
    func viewForZooming(in _: UIScrollView) -> UIView? {
        return nil
    }
}

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

        let chatButton = UIBarButtonItem(viewable: ChatButton(presentingViewController: viewController))

        viewController.navigationItem.rightBarButtonItems = [chatButton, restartButton]

        let titleHedvigLogo = UIImageView()
        titleHedvigLogo.image = Asset.wordmark.image
        titleHedvigLogo.contentMode = .scaleAspectFit

        viewController.navigationItem.titleView = titleHedvigLogo

        titleHedvigLogo.snp.makeConstraints { make in
            make.width.equalTo(80)
        }

        let webView = WKWebView(frame: .zero)
        webView.backgroundColor = .transparent
        webView.isOpaque = false
        webView.customUserAgent = ApolloClient.userAgent

        let doneButton = UIBarButtonItem(title: "done", style: .navigationBarButtonPrimary)

        bag += doneButton.onValue { _ in
            webView.resignFirstResponder()
        }

        webView.inputAssistantItem.trailingBarButtonGroups = [UIBarButtonItemGroup(barButtonItems: [doneButton], representativeItem: nil)]

        let view = UIView()
        view.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 1.00)
        viewController.view = view

        view.addSubview(webView)

        webView.snp.makeConstraints { make in
            make.top.bottom.trailing.leading.equalToSuperview()
        }

        bag += webView.didReceiveAuthenticationChallenge.set { (_, _) -> (URLSession.AuthChallengeDisposition, URLCredential?) in
            let credentials = URLCredential(user: "hedvig", password: "hedvig1234", persistence: .forSession)
            return (.useCredential, credentials)
        }

        bag += webView.signal(for: \.url).onValue { url in
            let urlString = String(describing: url)

            if urlString.contains("connect-payment") {
                viewController.present(PostOnboarding(), style: .defaultOrModal, options: [.defaults, .prefersNavigationBarHidden(true)])
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
                guard let url = URL(string: "https://www.hedvig.com/\(localePath)new-member?variation=ios#token=\(tokenString)") else {
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
                title: L10n.chatRestartAlertTitle,
                message: L10n.chatRestartAlertMessage,
                actions: [
                    Alert.Action(
                        title: L10n.chatRestartAlertConfirm,
                        action: {
                            loadWebOnboarding()
                        }
                    ),
                    Alert.Action(
                        title: L10n.chatRestartAlertCancel,
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
