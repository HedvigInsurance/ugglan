import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hAnalytics

extension JourneyPresentation {
    public var configureForeverTabBarItem: some JourneyPresentation {
        configureTabBarItemWithDot(
            ForeverStore.self,
            tabBarItem: UITabBarItem(
                title: L10n.tabReferralsTitle,
                image: Asset.tab.image,
                selectedImage: Asset.tabActive.image
            )
        ) { state in
            hAnalyticsExperiment.foreverFebruaryCampaign && !state.hasSeenFebruaryCampaign
        }
    }
}
