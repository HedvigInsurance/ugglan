import Flow
import Foundation
import Presentation
import UIKit
import hAnalytics
import hCore
import hCoreUI

extension JourneyPresentation {
    public var configureTabBarBorder: some JourneyPresentation {
        self.addConfiguration { presenter in
            presenter.bag += presenter.viewController.view.didMoveToWindowSignal.onValue({ _ in
                if let tabBarController = presenter.viewController.tabBarController {
                    tabBarController.tabBar.shadowImage = UIColor.clear.asImage()
                }
            })

            presenter.bag += presenter.viewController.view.didMoveFromWindowSignal.onValue({ _ in
                if let tabBarController = presenter.viewController.tabBarController {
                    tabBarController.tabBar.shadowImage = UIColor.brand(.primaryBorderColor).asImage()
                }
            })

        }
    }
}
