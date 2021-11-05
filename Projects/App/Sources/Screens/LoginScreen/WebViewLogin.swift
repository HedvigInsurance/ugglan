import Apollo
import Flow
import Foundation
import Presentation
import UIKit
import WebKit
import hCore
import hGraphQL

struct WebViewLogin {
    @Inject var client: ApolloClient
    let idNumber: String
}

extension WebViewLogin: Presentable {
    func materialize() -> (UIViewController, Signal<Void>) {
        let viewController = UIViewController()
        let bag = DisposeBag()

        let innerBag = DisposeBag()

        bag.hold(innerBag)

        let future = redirectUrl(bag: innerBag, text: idNumber)

        let webView = WKWebView(frame: .zero)
        webView.backgroundColor = .brand(.secondaryBackground())

        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .large
        activityIndicator.color = .brand(.primaryTintColor)
        activityIndicator.hidesWhenStopped = true

        webView.addSubview(activityIndicator)

        activityIndicator.startAnimating()

        activityIndicator.snp.makeConstraints { make in make.edges.equalToSuperview()
            make.size.equalToSuperview()
        }

        bag += webView.isLoadingSignal.onValue { isLoading in
            if isLoading { activityIndicator.alpha = 1 } else { activityIndicator.alpha = 0 }
        }

        viewController.view = webView

        bag += webView.decidePolicyForNavigationAction.set { _, navigationAction in
            guard let url = navigationAction.request.url else { return .allow }
            let urlString = String(describing: url)

            if urlString.contains("success") {
                return .cancel
            } else if urlString.contains("fail") {
                loadBankID()
                return .cancel
            }

            return .allow
        }

        func loadBankID() { bag += future.onValue { url in webView.load(URLRequest(url: url)) } }

        loadBankID()

        return (
            viewController,
            Signal { callback in
                bag += client.subscribe(subscription: GraphQL.AuthStatusSubscription())
                    .compactMap { $0.authStatus?.status }
                    .filter(predicate: { status -> Bool in status == .success }).take(first: 1)
                    .onValue { _ in callback(()) }
                return bag
            }
        )
    }
}

extension WebViewLogin {
    enum BankIDLoginError: Error { case invalidMarket }

    func redirectUrl(bag: DisposeBag, text: String) -> Future<URL> {
        Future { completion in
            switch Localization.Locale.currentLocale.market {
            case .dk:
                client.perform(mutation: GraphQL.NemIdAuthMutation(personalNumber: text))
                    .compactMap { $0.danishBankIdAuth.redirectUrl }.compactMap { URL(string: $0) }
                    .onValue { url in completion(.success(url)) }
            case .no:
                client.perform(mutation: GraphQL.BankIdNorwayAuthMutation(personalNumber: text))
                    .compactMap { $0.norwegianBankIdAuth.redirectUrl }
                    .compactMap { URL(string: $0) }.onValue { url in completion(.success(url)) }
            case .se: completion(.failure(BankIDLoginError.invalidMarket))
            }

            return bag
        }
    }
}
