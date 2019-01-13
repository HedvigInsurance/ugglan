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
import Presentation

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
                resultHandler: { (result: GraphQLResult<Query.Data>?, _: Error?) in
                    if result != nil {
                        completion(.success(result!))
                    } else {
                        self.showNetworkErrorMessage { [unowned self] in
                            self.fetch(
                                query: query,
                                cachePolicy: cachePolicy,
                                queue: queue
                            ).onResult({ result in
                                completion(result)
                            })
                        }
                    }
                }
            )

            return Disposer {
                cancellable.cancel()
            }
        }
    }

    func perform<Mutation: GraphQLMutation>(
        mutation: Mutation,
        queue: DispatchQueue = DispatchQueue.main
    ) -> Future<GraphQLResult<Mutation.Data>> {
        return Future<GraphQLResult<Mutation.Data>> { completion in
            let cancellable = self.perform(
                mutation: mutation,
                queue: queue,
                resultHandler: { (result: GraphQLResult<Mutation.Data>?, _: Error?) in
                    if result != nil {
                        completion(.success(result!))
                    } else {
                        self.showNetworkErrorMessage {
                            self.perform(mutation: mutation, queue: queue).onResult({ result in
                                completion(result)
                            })
                        }
                    }
                }
            )

            return Disposer {
                cancellable.cancel()
            }
        }
    }
}
