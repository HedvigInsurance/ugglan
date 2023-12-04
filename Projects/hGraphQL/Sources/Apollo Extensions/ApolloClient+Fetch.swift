import Apollo
import Combine
import Flow
import Foundation
import Presentation
import UIKit

extension GraphQLError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .graphQLError(let errors):
            let messages = errors.map { $0.localizedDescription }
            return messages.joined(separator: " ")
        case .otherError:
            return "Other error"
        }
    }
}

public enum GraphQLError: Error {
    case graphQLError(errors: [Error])
    case otherError
}

extension ApolloClient {
    public func fetch<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy = .returnCacheDataElseFetch,
        queue: DispatchQueue = DispatchQueue.main
    ) -> Flow.Future<Query.Data> {
        Future<Query.Data> { completion in
            let cancellable = self.fetch(
                query: query,
                cachePolicy: cachePolicy,
                contextIdentifier: nil,
                queue: queue
            ) { result in
                switch result {
                case let .success(result):
                    if let errors = result.errors {
                        completion(.failure(GraphQLError.graphQLError(errors: errors)))
                    } else if let data = result.data {
                        completion(.success(data))
                    }
                case let .failure(error): 
                    completion(.failure(GraphQLError.otherError))
                }
            }

            return Disposer { cancellable.cancel() }
        }
    }

    public func fetch<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy = .returnCacheDataElseFetch,
        queue: DispatchQueue = DispatchQueue.main
    ) async throws -> Query.Data {
        try await withCheckedThrowingContinuation {
            (inCont: CheckedContinuation<Query.Data, Error>) -> Void in
            self.fetch(
                query: query,
                cachePolicy: cachePolicy,
                contextIdentifier: nil,
                queue: queue
            ) { result in
                switch result {
                case let .success(result):
                    if let errors = result.errors {
                        inCont.resume(throwing: GraphQLError.graphQLError(errors: errors))
                    } else if let data = result.data {
                        inCont.resume(returning: data)
                    }
                case .failure:
                    inCont.resume(throwing: GraphQLError.otherError)
                }
            }
        }
    }

    public func refetchOnRefresh<Query: GraphQLQuery>(
        query: Query,
        refreshControl: UIRefreshControl,
        queue: DispatchQueue = DispatchQueue.main
    ) -> Disposable {
        refreshControl.onValue { [unowned self] _ in
            self.fetch(query: query, cachePolicy: .fetchIgnoringCacheData, queue: queue)
                .onValue { _ in refreshControl.endRefreshing() }
        }
    }

    public func perform<Mutation: GraphQLMutation>(
        mutation: Mutation,
        queue: DispatchQueue = DispatchQueue.main
    ) -> Flow.Future<Mutation.Data> {
        Future<Mutation.Data> { completion in
            let cancellable = self.perform(
                mutation: mutation,
                queue: queue,
                resultHandler: { result in
                    switch result {
                    case let .success(result):
                        if let data = result.data {
                            completion(.success(data))
                        } else if let errors = result.errors {
                            completion(.failure(GraphQLError.graphQLError(errors: errors)))
                        }
                    case let .failure(error): completion(.failure(error))
                    }
                }
            )

            return Disposer { cancellable.cancel() }
        }
    }

    public func perform<Mutation: GraphQLMutation>(
        mutation: Mutation,
        queue: DispatchQueue = DispatchQueue.main
    ) async throws -> Mutation.Data {
        return try await withCheckedThrowingContinuation {
            (inCont: CheckedContinuation<Mutation.Data, Error>) -> Void in
            self.perform(
                mutation: mutation,
                queue: queue
            ) { result in
                switch result {
                case let .success(result):
                    if let errors = result.errors {
                        inCont.resume(throwing: GraphQLError.graphQLError(errors: errors))
                    } else if let data = result.data {
                        inCont.resume(returning: data)
                    }
                case .failure:
                    inCont.resume(throwing: GraphQLError.otherError)
                }
            }
        }
    }

    public func watch<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy = .returnCacheDataElseFetch,
        queue _: DispatchQueue = DispatchQueue.main,
        onError: @escaping (_ error: Error) -> Void = { _ in }
    ) -> Signal<Query.Data> {
        Signal { callbacker in let bag = DisposeBag()

            let watcher: GraphQLQueryWatcher<Query> = self.watch(query: query, cachePolicy: cachePolicy) { result in
                switch result {
                case let .success(result):
                    if let data = result.data {
                        callbacker(data)
                    } else if let errors = result.errors {
                        onError(GraphQLError.graphQLError(errors: errors))
                    }
                case let .failure(error): onError(error)
                }
            }

            return Disposer {
                watcher.cancel()
                bag.dispose()
            }
        }
    }

    public func upload<Mutation: GraphQLMutation>(
        operation: Mutation,
        files: [GraphQLFile],
        queue: DispatchQueue = DispatchQueue.main
    ) -> Flow.Future<Mutation.Data> {
        Future { completion in let bag = DisposeBag()
            let cancellable = self.upload(operation: operation, files: files, queue: queue) { result in
                switch result {
                case let .success(result):
                    if let data = result.data {
                        completion(.success(data))
                    } else if let errors = result.errors {
                        completion(.failure(GraphQLError.graphQLError(errors: errors)))
                    }
                case let .failure(error):
                    completion(.failure(error))
                }
            }

            return Disposer {
                bag.dispose()
                cancellable.cancel()
            }
        }
    }

    public func subscribe<Subscription>(
        subscription: Subscription,
        queue: DispatchQueue = DispatchQueue.main,
        onError: @escaping (_ error: Error) -> Void = { _ in }
    ) -> Signal<Subscription.Data> where Subscription: GraphQLSubscription {
        Signal { callbacker in let bag = DisposeBag()

            let subscriber = self.subscribe(
                subscription: subscription,
                queue: queue,
                resultHandler: { result in
                    switch result {
                    case let .success(result):
                        if let data = result.data {
                            callbacker(data)
                        } else if let errors = result.errors {
                            onError(GraphQLError.graphQLError(errors: errors))
                        }
                    case let .failure(error): onError(error)
                    }
                }
            )

            bag += { subscriber.cancel() }

            return bag
        }
    }
}
