import Flow
import Foundation
import Presentation

extension JourneyPresentation {
    /// removes back button and disables interactive poping
    public var hidesBackButton: Self {
        addConfiguration { presenter in
            presenter.viewController.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            presenter.viewController.navigationItem.hidesBackButton = true
            presenter.bag += presenter.viewController.view.didLayoutSignal.onValue({ _ in
                presenter.viewController.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                presenter.viewController.navigationItem.hidesBackButton = true
            })
        }
    }

    /// shows back button and activates interactive poping
    public var showsBackButton: Self {
        addConfiguration { presenter in
            presenter.viewController.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            presenter.viewController.navigationItem.hidesBackButton = false
            presenter.bag += presenter.viewController.view.didLayoutSignal.onValue({ _ in
                presenter.viewController.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
                presenter.viewController.navigationItem.hidesBackButton = false
            })
        }
    }
}