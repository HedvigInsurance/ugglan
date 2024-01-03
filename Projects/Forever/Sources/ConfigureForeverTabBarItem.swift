import Flow
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI

extension JourneyPresentation {
    public var configureForeverTabBarItem: some JourneyPresentation {
        configureTabBarItemWithDot(
            ForeverStore.self,
            tabBarItem: UITabBarItem(
                title: L10n.tabReferralsTitle,
                image: hCoreUIAssets.foreverTab.image,
                selectedImage: hCoreUIAssets.foreverTabActive.image
            )
        ) { state in
            !state.hasSeenFebruaryCampaign
        }
    }
}
