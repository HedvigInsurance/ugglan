//
//  ApolloStore+Update.swift
//  ugglan
//
//  Created by Sam Pettersson on 2019-02-14.
//

import Apollo
import Foundation

extension ApolloStore {
    func update<Query: GraphQLQuery>(query: Query, updater: @escaping (inout Query.Data) -> Void) {
        withinReadWriteTransaction({ transaction in
            try transaction.update(query: query, updater)
        }, completion: nil)
    }
}
