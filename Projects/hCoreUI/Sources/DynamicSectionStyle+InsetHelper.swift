//
//  DynamicSectionStyle+Helpers.swift
//  hCoreUI
//
//  Created by Sam Pettersson on 2021-04-19.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation
import Form
import UIKit

extension DynamicSectionStyle {
    // sets row insets to provided UIEdgeInsets
    public func rowInsets(_ insets: UIEdgeInsets) -> DynamicSectionStyle {
        self.restyled { (style: inout SectionStyle) in
            style.rowInsets = insets
        }
    }
}
