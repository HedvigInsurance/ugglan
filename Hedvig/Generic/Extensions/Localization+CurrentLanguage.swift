//
//  Localization+CurrentLanguage.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-13.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Foundation

extension Localization.Language {
    static var currentLanguage: Localization.Language {
        let currentLanguage = Locale.current.languageCode

        if currentLanguage?.contains("sv") ?? false {
            return .sv_SE
        } else {
            return .sv_SE
        }
    }
}
