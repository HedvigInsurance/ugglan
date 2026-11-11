import Apollo
import Foundation
import SwiftUI

public enum GraphQLError: Error {
    case graphQLError(errors: [Apollo.GraphQLError])
    case otherError(error: Error)
}

@MainActor
extension ApolloClient {
    public func fetch<Query: GraphQLQuery>(
        query: Query
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
            graphQlLogger.error(
                "graphQL error \(query) response had neither data nor errors",
                error: nil,
                attributes: [:]
            )
            throw GraphQLError.graphQLError(errors: [])
        } catch let error as GraphQLError {
            // The throws above land here too, so without this they would be logged a second
            // time and re-wrapped as .otherError, losing the case the caller switches on.
            throw error
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
        } catch let error as GraphQLError {
            throw error
        } catch let error {
            logGraphQLException(errors: [error], for: mutation)
            throw GraphQLError.otherError(error: error)
        }
    }

    private func logGraphQLException(errors: [Swift.Error], for operation: any GraphQLOperation) {
        for error in errors {
            switch error {
            case let authError as AuthError:
                switch authError {
                case .refreshTokenExpired:
                    break
                case .refreshFailed:
                    graphQlLogger.error("graphQL auth refresh failed \(operation)", error: authError, attributes: [:])
                case .networkIssue:
                    graphQlLogger.warn("graphQL network issue \(operation)", error: authError, attributes: [:])
                }
            case let graphQLError as Apollo.GraphQLError:
                graphQlLogger.error(
                    "graphQL error \(operation) \(graphQLError)",
                    error: graphQLError,
                    attributes: [:]
                )
            default:
                if error.isCancellation {
                    graphQlLogger.debug("graphQL cancelled \(operation)", error: error, attributes: [:])
                } else if error.isUnreachableNetwork {
                    graphQlLogger.warn("graphQL network issue \(operation)", error: error, attributes: [:])
                } else {
                    graphQlLogger.error("graphQL error \(operation)", error: error, attributes: [:])
                }
            }
        }
    }
}

extension Swift.Error {
    // The caller went away mid-flight: a screen was dismissed or the query was superseded. Nothing
    // failed, so this must not reach the error stream — it is the single largest source of noise
    // in these logs.
    var isCancellation: Bool {
        if self is CancellationError { return true }
        let nsError = self as NSError
        return nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled
    }

    // Separates "the device never reached the network" from "the request reached it and failed".
    // Only the second says anything about the app or the backend, and logging both at the same
    // level is what made these logs unmonitorable.
    var isUnreachableNetwork: Bool {
        let nsError = self as NSError
        guard nsError.domain == NSURLErrorDomain else { return false }
        return [
            NSURLErrorNotConnectedToInternet,
            NSURLErrorNetworkConnectionLost,
            NSURLErrorCannotFindHost,
            NSURLErrorDNSLookupFailed,
            NSURLErrorInternationalRoamingOff,
            NSURLErrorDataNotAllowed,
            NSURLErrorCallIsActive,
        ]
        .contains(nsError.code)
    }
}
