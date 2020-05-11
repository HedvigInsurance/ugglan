//
//  ApolloClient+Flow.swift
//  Core
//
//  Created by Sam Pettersson on 2020-05-08.
//  Copyright © 2020 Hedvig AB. All rights reserved.
//

import Apollo
import Flow
import Foundation
import Presentation
import UIKit

private extension Error {
    var isIgnorable: Bool {
        return localizedDescription == "cancelled" || localizedDescription.contains("Apollo.WebSocketError") || localizedDescription.contains("Software caused connection abort")
    }
}

public extension ApolloClient {
    func fetch<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy = .returnCacheDataElseFetch,
        queue: DispatchQueue = DispatchQueue.main
    ) -> Future<GraphQLResult<Query.Data>> {
        return fetch(query: query, cachePolicy: cachePolicy, queue: queue, numberOfRetries: 0)
    }

    private func fetch<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy = .returnCacheDataElseFetch,
        queue: DispatchQueue = DispatchQueue.main,
        numberOfRetries: Int = 0
    ) -> Future<GraphQLResult<Query.Data>> {
        return Future<GraphQLResult<Query.Data>> { completion in
            let cancellable = self.fetch(query: query, cachePolicy: cachePolicy, context: nil, queue: queue) { [unowned self] result in
                switch result {
                case let .success(result):
                    completion(.success(result))
                case let .failure(error):
                    if error.isIgnorable {
                        return
                    }

                    let retryHandler = { [unowned self] () -> Void in
                        self.fetch(
                            query: query,
                            cachePolicy: cachePolicy,
                            queue: queue,
                            numberOfRetries: numberOfRetries + 1
                        ).onResult { result in
                            completion(result)
                        }
                    }

                    if numberOfRetries == 0 {
                        retryHandler()
                    } else {
                        //self.showNetworkErrorMessage(queue: queue, onRetry: retryHandler)
                    }
                }
            }

            return Disposer {
                cancellable.cancel()
            }
        }
    }

    func refetchOnRefresh<Query: GraphQLQuery>(
        query: Query,
        refreshControl: UIRefreshControl,
        queue: DispatchQueue = DispatchQueue.main
    ) -> Disposable {
        return refreshControl.onValue { [unowned self] _ in
            self.fetch(query: query, cachePolicy: .fetchIgnoringCacheData, queue: queue).onValue { _ in
                refreshControl.endRefreshing()
            }
        }
    }

    func perform<Mutation: GraphQLMutation>(
        mutation: Mutation,
        queue: DispatchQueue = DispatchQueue.main
    ) -> Future<GraphQLResult<Mutation.Data>> {
        return perform(mutation: mutation, queue: queue, numberOfRetries: 0)
    }

    private func perform<Mutation: GraphQLMutation>(
        mutation: Mutation,
        queue: DispatchQueue = DispatchQueue.main,
        numberOfRetries: Int = 0
    ) -> Future<GraphQLResult<Mutation.Data>> {
        return Future<GraphQLResult<Mutation.Data>> { completion in
            let cancellable = self.perform(
                mutation: mutation,
                queue: queue,
                resultHandler: { [unowned self] result in
                    switch result {
                    case let .success(result):
                        completion(.success(result))
                    case let .failure(error):
                        if error.isIgnorable {
                            return
                        }

                        let retryHandler = { [unowned self] () -> Void in
                            self.perform(mutation: mutation, queue: queue, numberOfRetries: numberOfRetries + 1).onResult { result in
                                completion(result)
                            }
                        }

                        if numberOfRetries == 0 {
                            retryHandler()
                        } else {
                            //self.showNetworkErrorMessage(queue: queue, onRetry: retryHandler)
                        }
                    }
                }
            )

            return Disposer {
                cancellable.cancel()
            }
        }
    }

    func watch<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy = .returnCacheDataElseFetch,
        queue: DispatchQueue = DispatchQueue.main
    ) -> Signal<GraphQLResult<Query.Data>> {
        return watch(query: query, cachePolicy: cachePolicy, queue: queue, numberOfRetries: 0)
    }

    private func watch<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy = .returnCacheDataElseFetch,
        queue: DispatchQueue = DispatchQueue.main,
        numberOfRetries: Int = 0
    ) -> Signal<GraphQLResult<Query.Data>> {
        return Signal { callbacker in
            let bag = DisposeBag()

            let watcher = self.watch(query: query, cachePolicy: cachePolicy, queue: queue) { [unowned self] result in
                switch result {
                case let .success(result):
                    callbacker(result)
                case let .failure(error):
                    if error.isIgnorable {
                        return
                    }

                    let retryHandler = { [unowned self] in
                        bag += self.watch(query: query, cachePolicy: cachePolicy, queue: queue, numberOfRetries: numberOfRetries + 1).onValue { result in
                            callbacker(result)
                        }
                    }

                    if numberOfRetries == 0 {
                        retryHandler()
                    } else {
                        //self.showNetworkErrorMessage(queue: queue, onRetry: retryHandler)
                    }
                }
            }

            return Disposer {
                watcher.cancel()
                bag.dispose()
            }
        }
    }

    func upload<Mutation: GraphQLMutation>(
        operation: Mutation,
        files: [GraphQLFile],
        queue: DispatchQueue = DispatchQueue.main
    ) -> Future<GraphQLResult<Mutation.Data>> {
        upload(operation: operation, files: files, queue: queue, numberOfRetries: 0)
    }

    private func upload<Mutation: GraphQLMutation>(
        operation: Mutation,
        files: [GraphQLFile],
        queue: DispatchQueue = DispatchQueue.main,
        numberOfRetries: Int = 0
    ) -> Future<GraphQLResult<Mutation.Data>> {
        Future { completion in
            let bag = DisposeBag()
            let cancellable = self.upload(operation: operation, context: nil, files: files, queue: queue) { [unowned self] result in
                print(result)
                switch result {
                case let .success(result):
                    completion(.success(result))
                case let .failure(error):
                    if error.isIgnorable {
                        return
                    }

                    let retryHandler = { [unowned self] () -> Void in
                        bag += self.upload(operation: operation, files: files, queue: queue).onValue { result in
                            completion(.success(result))
                        }
                    }

                    if numberOfRetries == 0 {
                        retryHandler()
                    } else {
                        //self.showNetworkErrorMessage(queue: queue, onRetry: retryHandler)
                    }
                }
            }

            return Disposer {
                bag.dispose()
                cancellable.cancel()
            }
        }
    }

    func subscribe<Subscription>(subscription: Subscription, queue: DispatchQueue = DispatchQueue.main) -> Signal<GraphQLResult<Subscription.Data>> where Subscription: GraphQLSubscription {
        return Signal { callbacker in
            let bag = DisposeBag()

            let subscriber = self.subscribe(subscription: subscription, queue: queue, resultHandler: { result in
                switch result {
                case let .success(result):
                    callbacker(result)
                case let .failure(error):
                    if !error.isIgnorable {
                        // log it
                    }
                }
            })

            return Disposer {
                subscriber.cancel()
                bag.dispose()
            }
        }
    }
}
