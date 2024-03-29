import Presentation
import SwiftUI
import hCore
import hCoreUI

extension JourneyPresentation {
    var configureContractsTabBarItem: some JourneyPresentation {
        configureTabBarItemWithDot(
            ContractStore.self,
            tabBarItem: UITabBarItem(
                title: L10n.tabInsurancesTitle,
                image: hCoreUIAssets.contractTab.image,
                selectedImage: hCoreUIAssets.contractTabActive.image
            )
        ) { state in
            state.hasUnseenCrossSell
        }
    }
}
