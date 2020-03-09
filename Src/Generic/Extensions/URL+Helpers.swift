//
//  URL+Helpers.swift
//  project
//
//  Created by Sam Pettersson on 2019-08-20.
//

import Foundation
import Space

extension URL {
    init?(key: Localization.Key) {
        guard let url = URL(string: String(key: key)) else {
            return nil
        }

        self = url
    }

    init?(string: String?) {
        guard let string = string, let url = URL(string: string) else {
            return nil
        }

        self = url
    }
}
