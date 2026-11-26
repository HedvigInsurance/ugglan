import Foundation
@preconcurrency import HedvigShared
import KMPNativeCoroutinesAsync
import KMPNativeCoroutinesCore
import hGraphQL

/// Throws a failure as the `GraphQLError` an Octopus client would. Runs on the caller's actor, so the read and its
/// value never cross an isolation boundary.
nonisolated(nonsending) func kotlinRead<Output>(
    _ read: () -> NativeSuspend<Output, Error, KotlinUnit>
) async throws -> Output {
    do {
        return try await asyncFunction(for: read())
    } catch {
        throw GraphQLError(readError: error)
    }
}

extension hGraphQL.GraphQLError {
    /// No answer, or no read failure at all (a cancellation, say), is `.otherError`; an answer the read could not use
    /// is `.graphQLError`. Kotlin has already logged the failure.
    init(readError error: Error) {
        let failure = (error as NSError).userInfo["KotlinException"] as? ReadFailure
        switch failure?.kind {
        case .network?, nil: self = .otherError(error: error)
        default: self = .graphQLError(errors: [])
        }
    }
}
