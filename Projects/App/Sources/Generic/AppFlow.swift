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
		bag += window.present(MainTabbedJourney.journey)
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
