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
    case graphQLError(errors: [Apollo.GraphQLError])
    case otherError(error: Error)
}

@MainActor
extension ApolloClient {
    public func fetch<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy.Query.SingleResponse = .networkOnly
    ) async throws -> Query.Data where Query.ResponseFormat == SingleResponseFormat {
        do {
            let response = try await fetch(
                query: query,
                cachePolicy: .networkOnly,
                requestConfiguration: .init(requestTimeout: 30, writeResultsToCache: false)
            )
            if let errors = response.errors {
                self.logGraphQLException(errors: errors, for: query)
                throw GraphQLError.graphQLError(errors: errors)
            } else if let data = response.data {
                return data
            }
            throw GraphQLError.graphQLError(errors: [])
        } catch let error {
            logGraphQLException(errors: [error], for: query)
            throw GraphQLError.otherError(error: error)
        }
    }

    public func mutation<Mutation: GraphQLMutation>(
        mutation: Mutation
    ) async throws -> Mutation.Data? where Mutation.ResponseFormat == SingleResponseFormat {
        do {
            let response = try await self.perform(
                mutation: mutation,
                requestConfiguration: .init(requestTimeout: 10, writeResultsToCache: false)
            )
            if let errors = response.errors {
                self.logGraphQLException(errors: errors, for: mutation)
                throw GraphQLError.graphQLError(errors: errors)
            } else if let data = response.data {
                return data
            } else {
                return nil
            }
        } catch let error {
            logGraphQLException(errors: [error], for: mutation)
            throw GraphQLError.otherError(error: error)
        }
    }

    private func logGraphQLException(errors: [Swift.Error], for operation: any GraphQLOperation) {
        for error in errors {
            if let error = error as? AuthError {
                switch error {
                case .refreshTokenExpired:
                    break
                case .refreshFailed:
                    graphQlLogger.error("graphQL error \(operation)", error: error, attributes: [:])
                case .networkIssue:
                    graphQlLogger.info("graphQL error \(operation)", error: error, attributes: [:])
                }
            } else if let error = error as? Error {
                graphQlLogger.info("graphQL error \(operation)", error: error, attributes: [:])
            } else if let error = error as? Apollo.GraphQLError {
                graphQlLogger.error("graphQL error \(error)", error: error, attributes: [:])
            } else {
                graphQlLogger.error("graphQL error \(operation)", error: error, attributes: [:])
            }
        }
    }
}
