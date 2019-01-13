//
//  String+Translation.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-06.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Foundation

extension String {
    static func translation(_ key: Localization.Key) -> String {
        switch Localization.Language.currentLanguage {
        case .sv_SE:
            return Localization.Translations.sv_SE.for(key: key)
        case .en_SE:
            // as we don't have things translated into english yet, just return sv_SE
            return Localization.Translations.sv_SE.for(key: key)
        }
    }
}
