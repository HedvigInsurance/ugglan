//
//  TranslationsRepo.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2019-01-13.
//  Copyright © 2019 Hedvig AB. All rights reserved.
//

import Apollo
import Foundation

struct TranslationsRepo {
    private static var translations: [String: String] = [:]

    static func fetch(client: ApolloClient) {
        let languageCode = String(describing: Localization.Language.currentLanguage)
        client.fetch(query: TranslationsQuery(code: languageCode)).onValue { result in
            let translations = result.data?.languages.first??.translations ?? []

            translations.forEach({ translation in
                if let key = translation.key?.value {
                    TranslationsRepo.translations[key] = translation.text
                }
            })
        }
    }

    static func find(_ key: Localization.Key) -> String? {
        let stringifiedKey = String(describing: key)
        return TranslationsRepo.translations[stringifiedKey]
    }
}
