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
                appearance.shadowColor = hBorderColor.translucentOne.colorFor(.light, .base).color.uiColor()
                appearance.backgroundImage = nil
                appearance.backgroundEffect = UIBlurEffect(style: .systemMaterialDark)
                DefaultStyling.applyCommonNavigationBarStyling(appearance)
                presenter.viewController.navigationController?.navigationBar.scrollEdgeAppearance = appearance
            })
        }
    }
}
