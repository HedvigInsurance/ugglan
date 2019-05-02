
//
//  LocalizationLocale+CurrentLocale.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-26.
//

import Foundation

extension Localization.Locale {
    func asGraphQLLocale() -> Locale {
        switch self {
        case .sv_SE:
            return .svSe
        case .en_SE:
            return .enSe
        }
    }
}
