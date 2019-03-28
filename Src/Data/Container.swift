//
//  Container.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-03-28.
//

import Foundation
import Apollo

class Container {
    static let shared = Container()
    
    var client: ApolloClient {
        DispatchQueue.main.async {
            return HedvigApolloClient.shared.client
        }
            }
    
}
