//
//  Journey+ScrollEdgeToStandard.swift
//  Journey+ScrollEdgeToStandard
//
//  Created by Sam Pettersson on 2021-10-08.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import Presentation
import Form
import Flow

extension JourneyPresentation {
    public var setScrollEdgeNavigationBarAppearanceToStandard: Self {
        addConfiguration { presenter in
            presenter.bag += presenter.viewController.view.didMoveToWindowSignal.onValue({ _ in
                presenter.viewController.navigationController?.navigationBar.scrollEdgeAppearance = DefaultStyling.standardNavigationBarAppearance()
            })
        }
    }
}
