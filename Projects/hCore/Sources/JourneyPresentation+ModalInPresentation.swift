import Foundation
import Presentation

extension JourneyPresentation {
    public var enableModalInPresentation: Self {
        addConfiguration { presenter in
            presenter.viewController.isModalInPresentation = true
        }
    }
    
    public var disableModalInPresentation: Self {
        addConfiguration { presenter in
            presenter.viewController.isModalInPresentation = false
            presenter.viewController.navigationController?.isModalInPresentation = false
        }
    }
}
