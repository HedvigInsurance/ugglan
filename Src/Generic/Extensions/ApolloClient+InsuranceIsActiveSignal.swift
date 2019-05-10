//
//  InsuranceIsActiveSignal.swift
//  UITests
//
//  Created by Sam Pettersson on 2019-05-09.
//

import Foundation
import Flow
import Apollo

extension ApolloClient {
    func insuranceIsActiveSignal() -> Signal<Bool> {
        return watch(
            query: InsuranceStatusQuery(),
            cachePolicy: .returnCacheDataAndFetch
        ).map { $0.data?.insurance.status == .some(.active) }
    }
}
