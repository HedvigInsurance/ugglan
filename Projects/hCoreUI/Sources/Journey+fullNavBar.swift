import Flow
import Form
import Foundation
import Presentation
import UIKit

extension JourneyPresentation {
    public var setScrollEdgeNavigationBarAppearanceToStandardd: Self {
        addConfiguration { presenter in
            presenter.bag += presenter.viewController.view.didMoveToWindowSignal.onValue({ _ in
                let appearance = UINavigationBarAppearance()
                appearance.configureWithTransparentBackground()
                appearance.backgroundColor = UIColor.brand(.primaryBackground())
                appearance.shadowColor = .clear
                appearance.backgroundImage = UIImage()
                appearance.backgroundEffect = UIBlurEffect(style: .systemThinMaterial)
                DefaultStyling.applyCommonNavigationBarStyling(appearance)
                presenter.viewController.navigationController?.navigationBar.scrollEdgeAppearance = appearance

                let standardAppearance = UINavigationBarAppearance()
                standardAppearance.configureWithTransparentBackground()
                standardAppearance.backgroundColor = UIColor.brand(.primaryBackground())
                standardAppearance.shadowColor = .clear
                standardAppearance.backgroundImage = UIImage()
                standardAppearance.backgroundEffect = UIBlurEffect(style: .systemThinMaterial)
                DefaultStyling.applyCommonNavigationBarStyling(standardAppearance)
                presenter.viewController.navigationController?.navigationBar.standardAppearance = standardAppearance
            })
        }
    }
}
