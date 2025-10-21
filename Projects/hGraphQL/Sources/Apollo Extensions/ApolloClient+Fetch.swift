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
    public func fetchQuery<Query: GraphQLQuery>(
        query: Query,
        cachePolicy: CachePolicy.Query.SingleResponse = .networkOnly
    ) async throws -> Query.Data where Query.ResponseFormat == SingleResponseFormat {
        do {
            let response = try await fetch(query: query, cachePolicy: .networkOnly, requestConfiguration: .init(requestTimeout: 30, writeResultsToCache: false))
            if let errors = response.errors {
//                self.logGraphQLException(error: GraphQLError2.graphQLError(errors: err), for: <#T##any GraphQLOperation#>)
//                self.logGraphQLException(error: GraphQLError2.graphQLError(errors: errors), for: query)
                throw GraphQLError.graphQLError(errors: errors)
            } else if let data = response.data {
                return data
            }
        } catch let error{
            throw  GraphQLError.otherError(error: error)
        }
        throw GraphQLError.graphQLError(errors: [])
    }

    public func performMutation<Mutation: GraphQLMutation>(
        mutation: Mutation,
        queue: DispatchQueue = DispatchQueue.main
    ) async throws -> Mutation.Data? where Mutation.ResponseFormat == SingleResponseFormat {
        do {
            let response = try await self.perform(mutation: mutation, requestConfiguration: .init(requestTimeout: 10, writeResultsToCache: false))
            if let errors = response.errors {
                //                self.logGraphQLException(error: GraphQLError2.graphQLError(errors: err), for: <#T##any GraphQLOperation#>)
                //                self.logGraphQLException(error: GraphQLError2.graphQLError(errors: errors), for: query)
                throw GraphQLError.graphQLError(errors: errors)
            } else if let data = response.data {
                return data
            } else {
                return nil
            }
        } catch let error {
            throw GraphQLError.otherError(error: error)
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
//        } else if let error = error as? ApolloURLSession.URLSessionClientError {
//            switch error {
//            case .networkError:
//                graphQlLogger.info("graphQL error \(operation)", error: error, attributes: [:])
//            default:
//                graphQlLogger.error("graphQL error \(operation)", error: error, attributes: [:])
//            }
        } else if let error = error as? GraphQLError {
            graphQlLogger.addError(error: error, type: .network, attributes: ["desc": error.logDescription])
            graphQlLogger.error("graphQL error \(error.logDescription)", error: error, attributes: [:])
        } else {
            graphQlLogger.error("graphQL error \(operation)", error: error, attributes: [:])
        }
    }
}
