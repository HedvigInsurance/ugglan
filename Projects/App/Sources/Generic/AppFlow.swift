import Embark
import Flow
import Foundation
import Offer
import Presentation
import UIKit
import hCore
import hCoreUI

public struct AppFlow {
	private let rootNavigationController = UINavigationController()

	let window: UIWindow
	let bag = DisposeBag()

	init(
		window: UIWindow
	) {
		self.window = window
		self.window.rootViewController = rootNavigationController
	}

	func presentLoggedIn() {
		let loggedIn = LoggedIn()
		bag += window.present(loggedIn)
	}
}

struct WebOnboardingFlow: Presentable {
	let webScreen: WebOnboardingScreen

	public func materialize() -> (UIViewController, Signal<Void>) {
		let (viewController, signal) = WebOnboarding(webScreen: webScreen).materialize()

		let bag = DisposeBag()

		return (
			viewController,
			Signal { callback in
				bag += signal.onValue { _ in
					bag +=
						viewController.present(
							PostOnboarding(),
							style: .detented(.large),
							options: [.prefersNavigationBarHidden(true)]
						)
						.onValue(callback)
				}

				return bag
			}
		)
	}
}

struct EmbarkOnboardingFlow: Presentable {
	public func materialize() -> (UIViewController, Disposable) {
		let menuChildren: [MenuChildable] = [
			MenuChild.appInformation,
			MenuChild.appSettings,
			MenuChild.login(onLogin: {
				UIApplication.shared.appDelegate.appFlow.presentLoggedIn()
			}),
		]

		let (viewController, signal) = EmbarkPlans(menu: Menu(title: nil, children: menuChildren)).materialize()
		viewController.navigationItem.largeTitleDisplayMode = .always
		let bag = DisposeBag()

		bag += signal.onValueDisposePrevious { story in
			let innerBag = DisposeBag()
			let embark = Embark(
				name: story.name,
				menu: Menu(
					title: nil,
					children: menuChildren
				)
			)

			innerBag +=
				viewController
				.present(
					embark,
					options: [.autoPop]
				)
				.onValue { redirect in
					switch redirect {
					case .mailingList:
						break
					case .close:
						break
					case let .offer(ids):
						innerBag +=
							viewController.present(
								Offer(
									offerIDContainer: .exact(
										ids: ids,
										shouldStore: true
									),
									menu: Menu(
										title: nil,
										children: menuChildren
									),
									options: [
										.menuToTrailing, .shouldPreserveState,
									]
								)
							)
							.atValue { value in
								switch value {
								case .signed:
									viewController.present(
										PostOnboarding(),
										options: [
											.prefersNavigationBarHidden(
												true
											)
										]
									)
								case .close:
									break
								case .chat:
									viewController.present(
										FreeTextChat().wrappedInCloseButton(),
										style: .detented(.large),
										options: [.defaults]
									)
								}
							}
							.onEnd {
								embark.goBack()
							}
					}
				}

			return innerBag
		}

		return (viewController, bag)
	}
}
