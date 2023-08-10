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
                        tabBarItem.badgeValue = nil
                        tabBarItem.badgeColor = .clear
                        presenter.viewController.tabBarItem = tabBarItem
                    }
                }
        }
    }
}
