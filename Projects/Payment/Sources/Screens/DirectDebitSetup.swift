import Apollo
import Flow
import Foundation
import hCore
import hGraphQL
import Presentation
import SafariServices
import UIKit
import WebKit

struct DirectDebitSetup {
	@Inject var client: ApolloClient
	@Inject var store: ApolloStore
	let setupType: PaymentSetup.SetupType

	private func makeDismissButton() -> UIBarButtonItem {
		switch setupType {
		case .postOnboarding:
			return UIBarButtonItem(
				title: L10n.PayInIframePostSign.skipButton,
				style: .brand(.body(color: .destructive))
			)
		default:
			return UIBarButtonItem(
				title: L10n.PayInIframeInApp.cancelButton,
				style: .brand(.body(color: .link))
			)
		}
	}

	init(setupType: PaymentSetup.SetupType = .initial) { self.setupType = setupType }
}

extension DirectDebitSetup: Presentable {
	func materialize() -> (UIViewController, Future<Void>) {
		let bag = DisposeBag()
		let viewController = UIViewController()
		viewController.hidesBottomBarWhenPushed = true

		if #available(iOS 13.0, *) { viewController.isModalInPresentation = true }

		switch setupType {
		case .replacement: viewController.title = L10n.PayInIframeInApp.connectPayment
		case .postOnboarding, .initial: viewController.title = L10n.PayInIframePostSign.title
		}

		let dismissButton = makeDismissButton()

		let userContentController = WKUserContentController()

		let webViewConfiguration = WKWebViewConfiguration()
		webViewConfiguration.userContentController = userContentController
		webViewConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = true
		webViewConfiguration.addOpenBankIDBehaviour(viewController)

		let webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
		webView.backgroundColor = .brand(.secondaryBackground())
		webView.isOpaque = false

		bag += webView.createWebViewWith.set { (_, _, navigationAction, _) -> WKWebView? in
			if navigationAction.targetFrame == nil {
				if let url = navigationAction.request.url {
					viewController.present(
						SFSafariViewController(url: url),
						animated: true,
						completion: nil
					)
				}
			}

			return nil
		}

		userContentController.add(
			TrustlyWKScriptOpenURLScheme(webView: webView),
			name: TrustlyWKScriptOpenURLScheme.NAME
		)

		viewController.view = webView

		bag += webView.didReceiveAuthenticationChallenge.set { _, challenge in
			if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
				let cred = URLCredential(trust: challenge.protectionSpace.serverTrust!)

				return (.useCredential, cred)
			}

			return (.performDefaultHandling, nil)
		}

		let activityIndicator = UIActivityIndicatorView()
		activityIndicator.style = .whiteLarge
		activityIndicator.color = .brand(.primaryTintColor)

		webView.addSubview(activityIndicator)

		activityIndicator.startAnimating()

		activityIndicator.snp.makeConstraints { make in make.edges.equalToSuperview()
			make.size.equalToSuperview()
		}

		bag += webView.isLoadingSignal.animated(style: AnimationStyle.easeOut(duration: 0.5)) { loading in
			if loading { activityIndicator.alpha = 1 } else { activityIndicator.alpha = 0 }
		}

		func startRegistration() {
			viewController.view = webView
			viewController.navigationItem.setLeftBarButton(dismissButton, animated: true)

			bag += client.perform(mutation: GraphQL.StartDirectDebitRegistrationMutation()).valueSignal
				.compactMap { $0.startDirectDebitRegistration }
				.onValue { startDirectDebitRegistration in
					webView.load(URLRequest(url: URL(string: startDirectDebitRegistration)!))
				}
		}

		startRegistration()

		return (
			viewController,
			Future { completion in
				bag += dismissButton.onValue {
					var alert: Alert<Bool>

					switch self.setupType {
					case .initial:
						alert = Alert<Bool>
							(
								title: L10n.PayInIframeInAppCancelAlert.title,
								message: L10n.PayInIframeInAppCancelAlert.body,
								actions: [
									Alert.Action(
										title: L10n.PayInIframeInAppCancelAlert
											.proceedButton
									) { true },
									Alert.Action(
										title: L10n.PayInIframeInAppCancelAlert
											.dismissButton
									) { false }
								]
							)
					case .postOnboarding:
						alert = Alert<Bool>
							(
								title: L10n.PayInIframePostSignSkipAlert.title,
								message: L10n.PayInIframePostSignSkipAlertDirectDebit
									.body,
								actions: [
									Alert.Action(
										title: L10n.PayInIframePostSignSkipAlert
											.proceedButton
									) { true },
									Alert.Action(
										title: L10n.PayInIframePostSignSkipAlert
											.dismissButton
									) { false }
								]
							)
					case .replacement:
						completion(.success)
						return
					}

					bag += viewController.present(alert)
						.onValue { shouldDismiss in
							if shouldDismiss {
								self.client
									.perform(
										mutation:
											GraphQL
											.CancelDirectDebitRequestMutation()
									)
									.onValue { _ in }
								completion(.success)
							}
						}
				}

				func showResultScreen(type: DirectDebitResultType) {
					viewController.navigationItem.setLeftBarButtonItems(nil, animated: true)

					let containerView = UIView()
					containerView.backgroundColor = .brand(.secondaryBackground())

					let directDebitResult = DirectDebitResult(type: type)

					switch type {
					case .success:
						client.fetch(query: GraphQL.PayInMethodStatusQuery())
							.onValue { _ in
								self.store.update(
									query: GraphQL.PayInMethodStatusQuery()
								) { (data: inout GraphQL.PayInMethodStatusQuery.Data) in
									data.payinMethodStatus = .pending
								}
							}
						ClearDirectDebitStatus.clear()
					case .failure: break
					}

					bag +=
						containerView.add(directDebitResult) { view in
							view.snp.makeConstraints { make in make.size.equalToSuperview()
								make.edges.equalToSuperview()
							}
						}
						.onValue { completion(.success) }
						.onError { _ in
							bag += Signal(after: 0.5).onValue { _ in startRegistration() }
						}

					viewController.view = containerView
				}

				bag += webView.decidePolicyForNavigationAction.set { _, navigationAction in
					guard let url = navigationAction.request.url else { return .allow }
					let urlString = String(describing: url)

					if urlString.contains("fail") || urlString.contains("success") {
						showResultScreen(
							type: urlString.contains("success")
								? .success(setupType: self.setupType)
								: .failure(setupType: self.setupType)
						)
						return .cancel
					}

					return .allow
				}

				// if user is closing app in the middle of process make sure to inform backend
				bag += NotificationCenter.default.signal(forName: .applicationWillTerminate)
					.onValue { _ in
						self.client
							.perform(mutation: GraphQL.CancelDirectDebitRequestMutation())
							.onValue { _ in }
					}

				return DelayedDisposer(bag, delay: 1)
			}
		)
	}
}
