//
//  ApolloClient+IsSwitching.swift
//  test
//
//  Created by Sam Pettersson on 2019-09-23.
//

import Apollo
import Flow
import Foundation

extension ApolloClient {
    var isSwitchingInsurance: Future<Bool> {
        fetch(query: ContractsQuery(locale: Localization.Locale.currentLocale.asGraphQLLocale())).map { result -> Bool in
            guard let data = result.data else { return false }
            return data.contracts.contains { contract -> Bool in
                contract.switchedFromInsuranceProvider != nil
            }
        }
    }
}
