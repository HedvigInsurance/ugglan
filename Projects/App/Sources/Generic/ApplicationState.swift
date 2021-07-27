import Flow
import Foundation
import Market
import Offer
import UIKit
import hCore
import hCoreUI
import hGraphQL

extension ApplicationState {
	private static let firebaseMessagingTokenKey = "firebaseMessagingToken"

	static func setFirebaseMessagingToken(_ token: String) {
		UserDefaults.standard.set(token, forKey: ApplicationState.firebaseMessagingTokenKey)
	}

	static func getFirebaseMessagingToken() -> String? {
		UserDefaults.standard.value(forKey: firebaseMessagingTokenKey) as? String
	}

	public static let lastNewsSeenKey = "lastNewsSeen"

	static func getLastNewsSeen() -> String {
		UserDefaults.standard.string(forKey: ApplicationState.lastNewsSeenKey) ?? "2.8.3"
	}

	static func setLastNewsSeen() {
		UserDefaults.standard.set(Bundle.main.appVersion, forKey: ApplicationState.lastNewsSeenKey)
	}

	static func presentRootViewController(_ window: UIWindow, animated: Bool = false) -> Disposable {
		guard let applicationState = currentState
		else {
			return window.present(
				MainJourney.journey
			)
		}

		switch applicationState {
		case .marketPicker, .languagePicker:
			return window.present(
				MainJourney.journey
			)
		case .marketing:
			return window.present(
				MainJourney.journey
			)
		case .onboardingChat, .onboarding:
			return window.present(
				OnboardingJourney.journey
			)
		case .offer:
			let bag = DisposeBag()

			preserveState(.marketPicker)
			bag +=
				presentRootViewController(
					window,
					animated: true
				)

			return bag
		case .loggedIn:
			return window.present(
				MainTabbedJourney.journey
			)
		}
	}
}
