//
//  ApolloClient+IsSwitching.swift
//  test
//
//  Created by Sam Pettersson on 2019-09-23.
//

import Foundation
import Apollo
import Flow

extension ApolloClient {
    var isSwitchingInsurance: Future<Bool> {
        fetch(query: SwitchingQuery()).map { result -> Bool in
            guard let data = result.data else { return false }
            return data.insurance.previousInsurer != nil && data.insurance.status.isInactive == true
        }
    }
}
