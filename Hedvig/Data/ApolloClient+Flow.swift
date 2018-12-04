//
//  ApolloClient+Flow.swift
//  Hedvig
//
//  Created by Sam Pettersson on 2018-11-29.
//  Copyright © 2018 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Foundation

extension ApolloClient {
    func fetch<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy = .returnCacheDataElseFetch,
        queue: DispatchQueue = DispatchQueue.main
    ) -> Future<GraphQLResult<Query.Data>> {
        return Future<GraphQLResult<Query.Data>> { completion in
            let cancellable = self.fetch(
                query: query,
                cachePolicy: cachePolicy,
                queue: queue,
                resultHandler: { (result: GraphQLResult<Query.Data>?, error: Error?) in
                    if result != nil {
                        completion(.success(result!))
                    } else {
                        completion(.failure(error!))
                    }
                }
            )

            return Disposer {
                cancellable.cancel()
            }
        }
    }
}
