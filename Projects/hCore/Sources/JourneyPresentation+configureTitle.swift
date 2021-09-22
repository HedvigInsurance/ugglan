import Flow
import Foundation
import Presentation
import UIKit

extension JourneyPresentation {
    /// set title of JourneyPresentations view controller
    public func configureTitle(_ title: String) -> Self {
        addConfiguration { presenter in
            guard let navigationController = presenter.viewController as? UINavigationController else {
                presenter.viewController.title = title
                return
            }

            navigationController.viewControllers.first?.title = title
        }
    }
}
