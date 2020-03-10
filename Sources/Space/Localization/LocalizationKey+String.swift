//
//  LocalizationKey+String.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-27.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Foundation

extension Localization.Key {
    public var description: String {
        var stringifiedKey = String(describing: self)

        if let parenthesisRange = stringifiedKey.range(of: "(") {
            stringifiedKey.removeSubrange(parenthesisRange.lowerBound ..< stringifiedKey.endIndex)
        }

        return stringifiedKey
    }
}
