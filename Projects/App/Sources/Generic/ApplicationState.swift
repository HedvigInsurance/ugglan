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
				MarketPicker(),
				options: [.defaults],
				animated: animated
			)
		}

		switch applicationState {
		case .marketPicker, .languagePicker:
			return window.present(
				MarketPicker(),
				options: [.defaults],
				animated: animated
			)
		case .marketing:
			return window.present(
				Marketing(),
				options: [.defaults],
				animated: animated
			)
		case .onboardingChat, .onboarding:
			return window.present(
				Onboarding(),
				options: [.defaults, .prefersLargeTitles(true)],
				animated: animated
			)
		case .offer:
			let bag = DisposeBag()

			preserveState(.onboarding)
			bag +=
				presentRootViewController(
					window,
					animated: true
				)

			return bag
		case .loggedIn:
			return window.present(
				LoggedIn(),
				options: [],
				animated: animated
			)
		}
	}
}
