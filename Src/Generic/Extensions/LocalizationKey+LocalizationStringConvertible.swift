//
//  LocalizationKey+LocalizationStringConvertible.swift
//  project
//
//  Created by Sam Pettersson on 2019-08-20.
//

import Foundation

extension Localization.Key: LocalizationStringConvertible {
    var localizationDescription: String {
        return String(key: self)
    }
}
