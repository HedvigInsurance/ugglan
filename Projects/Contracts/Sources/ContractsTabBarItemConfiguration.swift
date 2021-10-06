import Flow
import Presentation
import UIKit
import hCore
import hCoreUI

extension JourneyPresentation {
    var configureContractsTabBarItem: some JourneyPresentation {
        self.addConfiguration { presenter in
            let store: ContractStore = globalPresentableStoreContainer.get()

            let tabBarItem = UITabBarItem(
                title: L10n.InsurancesTab.title,
                image: Asset.tab.image,
                selectedImage: Asset.tabActive.image
            )

            presenter.bag += store.stateSignal.atOnce()
                .onValue { state in
                    if state.hasUnseenCrossSell {
                        tabBarItem.badgeValue = "●"
                        tabBarItem.badgeColor = .clear
                        tabBarItem.setBadgeTextAttributes(
                            [
                                NSAttributedString.Key.foregroundColor: UIColor.brand(.destructive),
                                NSAttributedString.Key.font: Fonts.fontFor(style: .subheadline),
                                NSAttributedString.Key.baselineOffset: 3,
                            ],
                            for: .normal
                        )

                        presenter.viewController.tabBarItem = tabBarItem
                    } else {
                        tabBarItem.badgeValue = ""
                        tabBarItem.badgeColor = .clear
                        presenter.viewController.tabBarItem = tabBarItem
                    }
                }
        }
    }
}
