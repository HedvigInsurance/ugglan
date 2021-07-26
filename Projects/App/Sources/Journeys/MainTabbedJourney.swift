import Contracts
import Flow
import Forever
import Form
import Foundation
import Home
import Presentation
import UIKit
import hCoreUI


struct MainTabbedJourney {
	static var homeTab: some JourneyPresentation {
		let home = Home(sections: Contracts.getSections())

		return Journey(home, options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)])
			.addConfiguration { presenter in
				presenter.viewController.tabBarItem = home.tabBarItem()
            }.onTabActive {
                ContextGradient.currentOption = .home
            }
	}

	static var contractsTab: some JourneyPresentation {
		let contracts = Contracts()

		return Journey(Contracts(), options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)])
			.addConfiguration { presenter in
				presenter.viewController.tabBarItem = contracts.tabBarItem()
			}.onTabActive {
                ContextGradient.currentOption = .none
            }
	}

	static var keyGearTab: some JourneyPresentation {
		let keyGearOverview = KeyGearOverview()

		return Journey(keyGearOverview, options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)])
			.addConfiguration { presenter in
				presenter.viewController.tabBarItem = keyGearOverview.tabBarItem()
			}.onTabActive {
                ContextGradient.currentOption = .none
            }
	}

	static var foreverTab: some JourneyPresentation {
		let forever = Forever(service: ForeverServiceGraphQL())

		return Journey(forever, options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)])
			.addConfiguration { presenter in
				presenter.viewController.tabBarItem = forever.tabBarItem()
			}.onTabActive {
                ContextGradient.currentOption = .forever
            }
	}

	static var profileTab: some JourneyPresentation {
		let profile = Profile()

		return Journey(Profile(), options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)])
			.addConfiguration { presenter in
				presenter.viewController.tabBarItem = profile.tabBarItem()
			}.onTabActive {
                ContextGradient.currentOption = .profile
            }
	}

	static var journey: some JourneyPresentation {
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
			.tabIndexReducer()
		}
	}
}
