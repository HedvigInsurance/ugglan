//
//  InsuranceIsActiveSignal.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-05-09.
//

import Apollo
import Flow
import Foundation

extension InsuranceStatus {
    var isInactive: Bool {
        switch self {
        case .inactive:
            return true
        case .inactiveWithStartDate:
            return true
        default:
            return false
        }
    }
}

extension ApolloClient {
    func insuranceIsActiveSignal() -> Signal<Bool> {
        return watch(
            query: InsuranceStatusQuery(),
            cachePolicy: .returnCacheDataAndFetch
        ).map { $0.data?.insurance.status == .some(.active) }
    }
}
