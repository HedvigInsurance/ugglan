import Apollo
import Flow
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit
import WebKit

struct WebOnboarding {
    @Inject var client: ApolloClient
    let webScreen: WebOnboardingScreen
}

extension WebOnboarding: Presentable {
    func materialize() -> (UIViewController, Disposable) {
        let viewController = UIViewController()
        let bag = DisposeBag()
        
        ApplicationState.preserveState(webScreen.screen)
        let urlConstructor = WebOnboardingState(screen: webScreen)

        let settingsButton = UIBarButtonItem()
        settingsButton.image = Asset.menuIcon.image
        settingsButton.tintColor = .brand(.primaryText())

        viewController.navigationItem.leftBarButtonItem = settingsButton

        bag += settingsButton.onValue { _ in
            viewController.present(
                About(state: .onboarding).withCloseButton,
                style: .detented(.scrollViewContentSize(20), .large),
                options: [
                    .allowSwipeDismissAlways,
                    .defaults,
                    .largeTitleDisplayMode(.always),
                    .prefersLargeTitles(true),
                ]
            )
        }

        let restartButton = UIBarButtonItem()
        restartButton.image = Asset.restart.image
        restartButton.tintColor = .brand(.primaryText())

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
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.allowsBackForwardNavigationGestures = true
        webView.customUserAgent = ApolloClient.userAgent

        let doneButton = UIBarButtonItem(title: "done", style: .brand(.headline(color: .link)))

        bag += doneButton.onValue { _ in
            webView.resignFirstResponder()
        }
        
        webView.inputAssistantItem.trailingBarButtonGroups = [UIBarButtonItemGroup(barButtonItems: [doneButton], representativeItem: nil)]

        let view = UIView()
        view.backgroundColor = .brand(.primaryBackground())
        viewController.view = view

        view.addSubview(webView)
        
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .whiteLarge
        activityIndicator.color = .brand(.primaryTintColor)
        activityIndicator.hidesWhenStopped = true

        webView.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        activityIndicator.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalToSuperview()
        }

        bag += webView.isLoadingSignal.onValue { loading in
            if loading {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
        }
        
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
                viewController.present(
                    PostOnboarding(),
                    style: .detented(.large)
                )
            }
        }
    
        func loadWebOnboarding() {
            guard let fragmentedUrl = urlConstructor.url else { return }
            webView.load(URLRequest(url: fragmentedUrl))
        }
        
        if webScreen == .webOffer {
            bag += urlConstructor.$offerIds.onValue { (ids) in
                guard !ids.isEmpty else { return }
                loadWebOnboarding()
            }
            
            bag += client.fetch(query: GraphQL.OfferQuery()).compactMap({ (offer) in
                return offer.lastQuoteOfMember.asCompleteQuote?.id
            }).onValue({ (id) in
                urlConstructor.$offerIds.value = [id]
            })
        } else {
            loadWebOnboarding()
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

        return (viewController, bag)
    }
}

internal extension Environment {
    var baseUrl: String {
        switch self {
            
        case .production:
            return "www.hedvig.com"
        case .staging:
            return "www.dev.hedvigit.com"
        case .custom:
            return "www.dev.hedvigit.com"
        }
    }
}
