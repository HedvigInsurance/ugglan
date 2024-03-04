import Claims
import Contracts
import Flow
import Form
import Foundation
import Home
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI

extension JourneyPresentation {
    func syncTabIndex() -> Self where P.Matter: UITabBarController {
        return addConfiguration { presenter in
            let store: UgglanStore = self.presentable.get()
            let tabBarController = presenter.matter

            tabBarController.selectedIndex = store.state.selectedTabIndex

            presenter.bag += tabBarController.signal(for: \.selectedViewController)
                .onValue { _ in
                    store.send(.setSelectedTabIndex(index: tabBarController.selectedIndex))
                }
        }
        .onState(UgglanStore.self) { state, presenter in
            presenter.matter.selectedIndex = state.selectedTabIndex
        }
    }

    /// Makes a tab active when store emits an action and true is returned in closure
    func makeTabSelected<S: Store>(
        _ storeType: S.Type,
        _ when: @escaping (_ action: S.Action) -> Bool
    ) -> Self {
        onAction(storeType) { action, presenter in
            guard let tabBarController = presenter.viewController.tabBarController else {
                return
            }

            if when(action),
                let presenterIndex = tabBarController.viewControllers?
                    .firstIndex(of: presenter.viewController)
            {
                tabBarController.selectedIndex = presenterIndex
            }
        }
    }
}

extension JourneyPresentation where P: Tabable {
    var configureTabBarItem: Self {
        addConfiguration { presenter in
            presenter.viewController.tabBarItem = self.presentable.tabBarItem()
        }
    }
}
