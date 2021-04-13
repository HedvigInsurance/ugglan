//
//  Localization.Locale.Market+Icon.swift
//  hCoreUI
//
//  Created by Sam Pettersson on 2021-04-09.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import hCore
import UIKit

extension Localization.Locale.Market {
    public var icon: UIImage {
        switch self {
        case .no:
            return hCoreUIAssets.flagNO.image
        case .se:
            return hCoreUIAssets.flagSE.image
        case .dk:
            return hCoreUIAssets.flagDK.image
        }
    }
}
