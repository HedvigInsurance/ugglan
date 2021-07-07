//
//  OfferIDContainer.swift
//  Offer
//
//  Created by Sam Pettersson on 2021-07-07.
//  Copyright © 2021 Hedvig AB. All rights reserved.
//

import Foundation

public enum OfferIDContainer {
    private static var storageKey = "OfferIDContainer"

    var ids: [String] {
        switch self {
        case .stored:
            return UserDefaults.standard.value(forKey: Self.storageKey) as? [String] ?? []
        case let .exact(ids, shouldStore):
            if shouldStore {
                UserDefaults.standard.set(ids, forKey: Self.storageKey)
            }

            return ids
        }
    }

    case stored
    case exact(ids: [String], shouldStore: Bool)
}
