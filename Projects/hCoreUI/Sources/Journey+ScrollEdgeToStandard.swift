import Flow
import Form
import Foundation
import Presentation

extension JourneyPresentation {
    public var setScrollEdgeNavigationBarAppearanceToStandard: Self {
        addConfiguration { presenter in
            presenter.bag += presenter.viewController.view.didMoveToWindowSignal.onValue({ _ in
                presenter.viewController.navigationController?.navigationBar.scrollEdgeAppearance =
                    DefaultStyling.standardNavigationBarAppearance()
            })
        }
    }
}
