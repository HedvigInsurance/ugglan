import Contracts
import Flow
import Forever
import Form
import Foundation
import Home
import Presentation
import UIKit
import hCore
import hCoreUI

extension AppJourney {
	fileprivate static var homeTab: some JourneyPresentation {
		let home = Home(sections: [
			HomeSection(
				title: L10n.HomeTab.editingSectionTitle,
				style: .vertical,
				children: [
					.init(
						title: L10n.HomeTab.editingSectionChangeAddressLabel,
						icon: hCoreUIAssets.apartment.image,
						handler: { viewController in
							viewController.present(
								MovingFlowJourney.journey
							)
							.onValue { _ in }
							return NilDisposer()
						}
					)
				]
			)
		])

		return Journey(home, options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)])
			.configureTabBarItem
			.onTabSelected {
				ContextGradient.currentOption = .home
			}
	}

	fileprivate static var contractsTab: some JourneyPresentation {
		Journey(
			Contracts(),
			options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)]
		) { result in
			switch result {
			case .movingFlow:
				MovingFlowJourney.journey
			}
		}
		.configureTabBarItem
		.onTabSelected {
			ContextGradient.currentOption = .none
		}
	}

	fileprivate static var keyGearTab: some JourneyPresentation {
		Journey(
			KeyGearOverview(),
			options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)]
		)
		.configureTabBarItem
		.onTabSelected {
			ContextGradient.currentOption = .none
		}
	}

	fileprivate static var foreverTab: some JourneyPresentation {
		Journey(
			Forever(service: ForeverServiceGraphQL()),
			options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)]
		)
		.configureTabBarItem
		.onTabSelected {
			ContextGradient.currentOption = .forever
		}
		.makeTabSelected(UgglanStore.self) { action in
			action == .makeForeverTabActive
		}
	}

	fileprivate static var profileTab: some JourneyPresentation {
		Journey(
			Profile(),
			options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)]
		)
		.configureTabBarItem
		.onTabSelected {
			ContextGradient.currentOption = .profile
		}
	}

	static var loggedIn: some JourneyPresentation {
		Journey(FeaturesLoader(), options: []) { features in
			TabbedJourney(
				{
					homeTab
				},
				{
					contractsTab
				},
				{
					if features.contains(.keyGear) {
						keyGearTab
					}
				},
				{
					if features.contains(.referrals) {
						foreverTab
					}
				},
				{
					profileTab
				}
			)
			.syncTabIndex()
		}
		.onPresent {
			ApplicationState.preserveState(.loggedIn)
			AnalyticsCoordinator().setUserId()

			if let fcmToken = ApplicationState.getFirebaseMessagingToken() {
				UIApplication.shared.appDelegate.registerFCMToken(fcmToken)
			}
		}
	}
}
