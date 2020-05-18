//
//  KeyGearItemQuery+Convenience.swift
//  test
//
//  Created by Sam Pettersson on 2020-02-20.
//

import Foundation

extension KeyGearItemQuery {
    convenience init(id: String) {
        self.init(id: id, languageCode: Localization.Locale.currentLocale.code)
    }
}
