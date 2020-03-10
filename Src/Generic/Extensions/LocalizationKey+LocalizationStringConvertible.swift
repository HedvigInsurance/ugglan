//
//  LocalizationKey+LocalizationStringConvertible.swift
//  project
//
//  Created by Sam Pettersson on 2019-08-20.
//

import Foundation
import Space

extension Localization.Key: LocalizationStringConvertible {
    public var localizationDescription: String {
        return String(key: self)
    }
}
