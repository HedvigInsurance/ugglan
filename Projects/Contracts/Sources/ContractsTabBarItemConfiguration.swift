import Flow
import Presentation
import UIKit
import hCore
import hCoreUI

extension JourneyPresentation {
    var configureContractsTabBarItem: some JourneyPresentation {
        configureTabBarItemWithDot(
            ContractStore.self,
            tabBarItem: UITabBarItem(
                title: L10n.InsurancesTab.title,
                image: Asset.tab.image,
                selectedImage: Asset.tabActive.image
            )
        ) { state in
            state.hasUnseenCrossSell
        }
    }
}
