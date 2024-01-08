import Flow
import Foundation
import Presentation
import UIKit
import hCore

extension JourneyPresentation {
    public func configureTabBarItemWithDot<S: Store>(
        _ storeType: S.Type,
        tabBarItem: UITabBarItem,
        showDot: @escaping (_ state: S.State) -> Bool
    ) -> some JourneyPresentation {
        self.addConfiguration { presenter in
            let store: S = globalPresentableStoreContainer.get()

            presenter.bag += store.stateSignal.atOnce()
                .onValue { state in
                    if showDot(state) {
                        tabBarItem.badgeValue = ""
                        presenter.viewController.tabBarItem = tabBarItem
                    } else {
                        tabBarItem.badgeValue = nil
                        presenter.viewController.tabBarItem = tabBarItem
                    }
                }
        }
    }
}
