import Apollo
import SwiftUI

extension hGraphQL.GraphQLError {
    var logDescription: String {
        switch self {
        case let .graphQLError(errors):
            let messages = errors.map(\.localizedDescription)
            return messages.joined(separator: " ")
        case let .otherError(error):
            return "Other error \(error)"
        }
    }
}

public enum GraphQLError: Error {
    case graphQLError(errors: [Error])
    case otherError(error: Error)
}

@MainActor
extension ApolloClient {
    public func fetch<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy = .returnCacheDataElseFetch,
        queue: DispatchQueue = DispatchQueue.main
    ) async throws -> Query.Data {
        try await withCheckedThrowingContinuation {
            (inCont: CheckedContinuation<Query.Data, Error>) in
            self.fetch(
                query: query,
                cachePolicy: cachePolicy,
                contextIdentifier: nil,
                queue: queue
            ) { [weak self] result in
                switch result {
                case let .success(result):
                    if let errors = result.errors {
                        self?.logGraphQLException(error: GraphQLError.graphQLError(errors: errors), for: query)
                        inCont.resume(throwing: GraphQLError.graphQLError(errors: errors))
                    } else if let data = result.data {
                        Task { @MainActor in
                            inCont.resume(returning: data)
                        }
                    }
                case let .failure(error):
                    self?.logGraphQLException(error: error, for: query)
                    inCont.resume(throwing: GraphQLError.otherError(error: error))
                }
            }
        }
    }

    public func perform<Mutation: GraphQLMutation>(
        mutation: Mutation,
        queue: DispatchQueue = DispatchQueue.main
    ) async throws -> Mutation.Data {
        try await withCheckedThrowingContinuation {
            (inCont: CheckedContinuation<Mutation.Data, Error>) in
            self.perform(
                mutation: mutation,
                queue: queue
            ) { [weak self] result in
                switch result {
                case let .success(result):
                    if let errors = result.errors {
                        self?.logGraphQLException(error: GraphQLError.graphQLError(errors: errors), for: mutation)
                        inCont.resume(throwing: GraphQLError.graphQLError(errors: errors))
                    } else if let data = result.data {
                        Task { @MainActor in
                            inCont.resume(returning: data)
                        }
                    }
                case let .failure(error):
                    self?.logGraphQLException(error: error, for: mutation)
                    inCont.resume(throwing: GraphQLError.otherError(error: error))
                }
            }
        }
    }

    private func logGraphQLException(error: Error, for operation: any GraphQLOperation) {
        if let error = error as? AuthError {
            switch error {
            case .refreshTokenExpired:
                break
            case .refreshFailed:
                graphQlLogger.error("graphQL error \(operation)", error: error, attributes: [:])
            case .networkIssue:
                graphQlLogger.info("graphQL error \(operation)", error: error, attributes: [:])
            }
        } else if let error = error as? URLSessionClient.URLSessionClientError {
            switch error {
            case .networkError:
                graphQlLogger.info("graphQL error \(operation)", error: error, attributes: [:])
            default:
                graphQlLogger.error("graphQL error \(operation)", error: error, attributes: [:])
            }
        } else if let error = error as? GraphQLError {
            graphQlLogger.addError(error: error, type: .network, attributes: ["desc": error.logDescription])
            graphQlLogger.error("graphQL error \(error.logDescription)", error: error, attributes: [:])
        } else {
            graphQlLogger.error("graphQL error \(operation)", error: error, attributes: [:])
        }
    }
}
