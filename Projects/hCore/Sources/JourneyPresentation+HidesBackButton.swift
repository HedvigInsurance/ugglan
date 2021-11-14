//
//  JourneyPresentation+HidesBackButton.swift
//  hCore
//
//  Created by Sam Pettersson on 2021-11-14.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import Presentation

extension JourneyPresentation {
    public var hidesBackButton: Self {
        addConfiguration { presenter in
            presenter.viewController.navigationItem.hidesBackButton = true
        }
    }
}
