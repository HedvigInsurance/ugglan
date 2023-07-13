import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI

extension JourneyPresentation {
    func configureHomeScroll() -> some JourneyPresentation {
        self.addConfiguration({ presenter in
            let scrollEdgeAppearance = UINavigationBarAppearance()
            DefaultStyling.applyCommonNavigationBarStyling(scrollEdgeAppearance)
            scrollEdgeAppearance.configureWithTransparentBackground()
            scrollEdgeAppearance.largeTitleTextAttributes = scrollEdgeAppearance.largeTitleTextAttributes
                .merging(
                    [
                        NSAttributedString.Key.foregroundColor: UIColor.clear
                    ],
                    uniquingKeysWith: takeRight
                )

            guard let navigationController = presenter.viewController as? UINavigationController else {
                presenter.viewController.navigationItem.scrollEdgeAppearance = scrollEdgeAppearance
                return
            }
            navigationController.viewControllers.first?.navigationItem.scrollEdgeAppearance = scrollEdgeAppearance
            presenter.viewController.navigationItem.scrollEdgeAppearance = scrollEdgeAppearance
        })
    }
}
