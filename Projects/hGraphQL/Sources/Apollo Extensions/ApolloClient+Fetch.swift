import Apollo
import Flow
import Foundation
import Presentation
import UIKit

struct GraphQLStandardError: Error { var errors: [Error] }

enum ErrorCode: String {
    case invalidVersion = "invalid_version"
}

struct InvalidVersionError: Error {
    let errorCode: ErrorCode
    let message: String
    let supportPhoneNumber: String?
    let supportEmail: String?
    let errorMessage: String
    
    init(from extensions: [String: String], _ message: String) {
        self.errorCode = ErrorCode(rawValue: extensions["errorCode"] ?? "") ?? .invalidVersion
        self.message = message
        self.supportPhoneNumber = extensions["supportPhoneNumber"]
        self.supportEmail = extensions["supportEmail"]
        self.errorMessage = extensions["errorMessage"] ?? ""
    }
}

struct VersionErrorHandler {
    func getVersionError(from errors: [GraphQLError]?) -> InvalidVersionError? {
        guard let errors = errors else { return nil }
        
        guard let validError = errors.first(where: { error in
            if let extensions = error.extensions, let errorCode = extensions["errorCode"] as? String {
                return errorCode == ErrorCode.invalidVersion.rawValue
            } else { return false }
        }) else { return nil }
        
        guard let extensions = validError.extensions as? [String: String] else { return nil }
        guard let message = validError.message else { return nil }
        let versionError = InvalidVersionError(from: extensions, message)
        return versionError
    }
}

extension ApolloClient {
    public func fetch<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy = .returnCacheDataElseFetch,
        queue: DispatchQueue = DispatchQueue.main
    ) -> Future<Query.Data> {
        Future<Query.Data> { completion in
            let cancellable = self.fetch(
                query: query,
                cachePolicy: cachePolicy,
                contextIdentifier: nil,
                queue: queue
            ) { result in
                switch result {
                case let .success(result):
                    if let data = result.data {
                        completion(.success(data))
                    } else if let errors = result.errors {
                        /*if let versionError = VersionErrorHandler().getVersionError(from: errors) {
                            
                        }*/
                        //print("GERROR 1:", VersionErrorHandler().getVersionError(from: errors))
                        completion(.failure(GraphQLStandardError(errors: errors)))
                    }
                case let .failure(error): completion(.failure(error))
                }
            }

            return Disposer { cancellable.cancel() }
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
    ) -> Future<Mutation.Data> {
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
                            completion(.failure(GraphQLStandardError(errors: errors)))
                        }
                    case let .failure(error): completion(.failure(error))
                    }
                }
            )

            return Disposer { cancellable.cancel() }
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
                        let errs = errors.first!
                        print("GERROR 2:", errs["supportEmail"])
                        onError(GraphQLStandardError(errors: errors))
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
    ) -> Future<Mutation.Data> {
        Future { completion in let bag = DisposeBag()
            let cancellable = self.upload(operation: operation, files: files, queue: queue) { result in
                switch result {
                case let .success(result):
                    if let data = result.data {
                        completion(.success(data))
                    } else if let errors = result.errors {
                        completion(.failure(GraphQLStandardError(errors: errors)))
                    }
                case let .failure(error): completion(.failure(error))
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
                            onError(GraphQLStandardError(errors: errors))
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
