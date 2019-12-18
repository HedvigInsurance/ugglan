
//
//  LocalizationLocale+CurrentLocale.swift
//  project
//
//  Created by Sam Pettersson on 2019-04-26.
//

import Foundation

extension Localization.Locale {
    var acceptLanguageHeader: String {
        switch self {
        case .sv_SE:
            return "sv-SE"
        case .en_SE:
            return "en-SE"
        }
    }
    
    var code: String {
       switch self {
       case .sv_SE:
           return "sv_SE"
       case .en_SE:
           return "en_SE"
       }
   }

    func asGraphQLLocale() -> Locale {
        switch self {
        case .sv_SE:
            return .svSe
        case .en_SE:
            return .enSe
        }
    }
}
