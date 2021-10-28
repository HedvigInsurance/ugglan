import Foundation
import Presentation

extension JourneyPresentation {
    public var hidesBackButton: Self {
        addConfiguration { presenter in
            presenter.viewController.navigationItem.hidesBackButton = true
        }
    }
}
