import Apollo
import SwiftUI

extension GraphQLError {
    var logDescription: String? {
        switch self {
        case .graphQLError(let errors):
            let messages = errors.map { $0.localizedDescription }
            return messages.joined(separator: " ")
        case .otherError(let error):
            return "Other error \(error)"
        }
    }
}

public enum GraphQLError: Error {
    case graphQLError(errors: [Error])
    case otherError(error: Error)
}

func logGraphQLError(error: GraphQLError) {
    Task { @MainActor in
        log.addError(error: error, type: .network, attributes: ["desc": error.logDescription])
    }
}

@MainActor
extension ApolloClient {
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
                        logGraphQLError(error: .graphQLError(errors: errors))
                        inCont.resume(throwing: GraphQLError.graphQLError(errors: errors))
                    } else if let data = result.data {
                        Task { @MainActor in
                            inCont.resume(returning: data)
                        }
                    }
                case let .failure(error):
                    inCont.resume(throwing: GraphQLError.otherError(error: error))
                }
            }
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
                        logGraphQLError(error: .graphQLError(errors: errors))
                        inCont.resume(throwing: GraphQLError.graphQLError(errors: errors))
                    } else if let data = result.data {
                        Task { @MainActor in
                            inCont.resume(returning: data)
                        }
                    }
                case .failure(let error):
                    inCont.resume(throwing: GraphQLError.otherError(error: error))
                }
            }
        }
    }
}
