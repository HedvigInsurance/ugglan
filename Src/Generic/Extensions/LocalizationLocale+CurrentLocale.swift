
//
//  LocalizationLocale+CurrentLocale.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-26.
//

import Foundation
import Space

extension Localization.Locale {
    var acceptLanguageHeader: String {
        switch self {
        case .sv_SE:
            return "sv-SE"
        case .en_SE:
            return "en-SE"
        case .en_NO:
            return "en-NO"
        case .nb_NO:
            return "nb-NO"
        }
    }

    var code: String {
        switch self {
        case .sv_SE:
            return "sv_SE"
        case .en_SE:
            return "en_SE"
        case .en_NO:
            return "en_NO"
        case .nb_NO:
            return "nb_NO"
        }
    }

    func asGraphQLLocale() -> Space.Locale {
        switch self {
        case .sv_SE:
            return .svSe
        case .en_SE:
            return .enSe
        case .nb_NO:
            return .enSe
        case .en_NO:
            return .enSe
        }
    }
}
