import Foundation
import Presentation

extension JourneyPresentation {
    /// removes back button and disables interactive poping
    public var hidesBackButton: Self {
        addConfiguration { presenter in
            presenter.viewController.navigationItem.hidesBackButton = true
            presenter.viewController.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
    }

    /// shows back button and activates interactive poping
    public var showsBackButton: Self {
        addConfiguration { presenter in
            presenter.viewController.navigationItem.hidesBackButton = false
            presenter.viewController.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        }
    }
}
