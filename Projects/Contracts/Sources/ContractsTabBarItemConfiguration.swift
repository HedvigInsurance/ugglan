import Presentation
import hCoreUI
import hCore
import Flow
import UIKit

extension JourneyPresentation where P == Contracts {
    public var configureContractsTabBarItem: some JourneyPresentation {
        self.addConfiguration { presenter in
            let store: ContractStore = globalPresentableStoreContainer.get()
            
            let tabBarItem = self.presentable.tabBarItem()
                        
            presenter.bag += store.stateSignal.atOnce().onValue { state in
                if state.hasUnseenCrossSell {
                    tabBarItem.badgeValue = "●"
                    tabBarItem.badgeColor = .clear
                    tabBarItem.setBadgeTextAttributes([
                        NSAttributedString.Key.foregroundColor: UIColor.brand(.destructive),
                        NSAttributedString.Key.font: Fonts.fontFor(style: .subheadline),
                        NSAttributedString.Key.baselineOffset: 3
                    ], for: .normal)
                    
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
