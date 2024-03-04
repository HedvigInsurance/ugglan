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
                image: hCoreUIAssets.contractTab.image,
                selectedImage: hCoreUIAssets.contractTabActive.image
            )
        ) { state in
            state.hasUnseenCrossSell
        }
    }
}
