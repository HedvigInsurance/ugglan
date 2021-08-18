import Apollo
import Flow
import Foundation
import Presentation
import UIKit
import WebKit
import hCore
import hCoreUI
import hGraphQL

struct WebOnboarding {
  @Inject var client: ApolloClient
  let webScreen: WebOnboardingScreen
}

enum WebOnboardingResult {
  case menu(action: MenuChildAction)
  case postOnboarding
}

extension WebOnboarding: Presentable {
  func materialize() -> (UIViewController, Signal<WebOnboardingResult>) {
    let viewController = UIViewController()
    let bag = DisposeBag()

    let urlConstructor = WebOnboardingState(screen: webScreen)

    let settingsButton = UIBarButtonItem()
    settingsButton.image = Asset.menuIcon.image
    settingsButton.tintColor = .brand(.primaryText())

    let restartButton = UIBarButtonItem()
    restartButton.image = Asset.restart.image
    restartButton.tintColor = .brand(.primaryText())

    let chatButton = UIBarButtonItem(viewable: ChatButton(presentingViewController: viewController))

    switch webScreen {
    case .webOnboarding:
      viewController.navigationItem.titleView = .titleWordmarkView
      viewController.navigationItem.leftBarButtonItem = settingsButton
      viewController.navigationItem.rightBarButtonItems = [chatButton, restartButton]
    case .webOffer:
      viewController.navigationItem.titleView = nil
      viewController.title = L10n.offerTitle
      viewController.navigationItem.rightBarButtonItems = [chatButton, settingsButton]
    }

    let webView = WKWebView(frame: .zero)
    webView.backgroundColor = .clear
    webView.isOpaque = false
    webView.allowsBackForwardNavigationGestures = true
    webView.customUserAgent = ApolloClient.userAgent

    let doneButton = UIBarButtonItem(title: "done", style: .brand(.headline(color: .link)))

    bag += doneButton.onValue { _ in webView.resignFirstResponder() }

    webView.inputAssistantItem.trailingBarButtonGroups = [
      UIBarButtonItemGroup(barButtonItems: [doneButton], representativeItem: nil)
    ]

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

    activityIndicator.snp.makeConstraints { make in make.edges.equalToSuperview()
      make.size.equalToSuperview()
    }

    bag += webView.isLoadingSignal.onValue { loading in
      if loading { activityIndicator.startAnimating() } else { activityIndicator.stopAnimating() }
    }

    webView.snp.makeConstraints { make in make.top.bottom.trailing.leading.equalToSuperview() }

    bag += webView.didReceiveAuthenticationChallenge.set {
      (_, _) -> (URLSession.AuthChallengeDisposition, URLCredential?) in
      let credentials = URLCredential(
        user: "hedvig",
        password: "hedvig1234",
        persistence: .forSession
      )
      return (.useCredential, credentials)
    }

    func loadWebOnboarding() {
      guard let url = urlConstructor.url else { return }
      let dataStore = WKWebsiteDataStore.default()

      dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
        records.forEach { record in
          dataStore.removeData(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
            for: [record]
          ) {}
        }

        webView.load(URLRequest(url: url))
      }
    }

    bag += restartButton.onValue { _ in
      let alert = Alert(
        title: L10n.chatRestartAlertTitle,
        message: L10n.chatRestartAlertMessage,
        actions: [
          Alert.Action(
            title: L10n.chatRestartAlertConfirm,
            action: { loadWebOnboarding() }
          ), Alert.Action(title: L10n.chatRestartAlertCancel, action: {}),
        ]
      )

      viewController.present(alert)
    }

    loadWebOnboarding()

    return (
      viewController,
      Signal { callback in

        bag += settingsButton.attachSinglePressMenu(
          viewController: viewController,
          menu: Menu(
            title: "",
            children: [
              MenuChild.appInformation,
              MenuChild.appSettings,
              MenuChild.login,
            ]
          )
        ) { action in
          callback(.menu(action: action))
        }

        bag += webView.signal(for: \.url)
          .map { url in let urlString = String(describing: url)

            if urlString.contains("connect-payment") { callback(.postOnboarding) }
          }

        return bag
      }
    )
  }
}
