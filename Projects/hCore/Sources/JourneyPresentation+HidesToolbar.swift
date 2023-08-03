import Foundation
import Presentation

extension JourneyPresentation {
    public var hidesBottomBarWhenPushed: Self {
        addConfiguration { presenter in
            presenter.viewController.hidesBottomBarWhenPushed = true
        }
    }
}
