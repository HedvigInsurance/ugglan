import Foundation
@preconcurrency import HedvigShared
import KMPNativeCoroutinesAsync
import KMPNativeCoroutinesCore
import hGraphQL

/// Throws a failure carrying text the backend wrote for the member as a `MemberFacingError`, a cancelled read, from
/// either side, as `CancellationError`, and any other failure as the `GraphQLError` an Octopus client would. Runs on
/// the caller's actor, so the read and its value never cross an isolation boundary.
nonisolated(nonsending) func kotlinRead<Output>(
    _ read: () -> NativeSuspend<Output, Error, KotlinUnit>
) async throws -> Output {
    do {
        return try await asyncFunction(for: read())
    } catch let error as CancellationError {
        throw error
    } catch {
        if let message = (error as NSError).readFailure?.memberFacingMessage {
            throw MemberFacingError(message: message)
        }
        throw GraphQLError(readError: error)
    }
}

/// A failed read the backend answered with a message for the member, such as a `userError`. Views show it through
/// `localizedDescription`. A client whose feature has its own error type maps it there, as in
/// `catch let error as MemberFacingError { throw AddonsError.errorMessage(message: error.message) }`.
struct MemberFacingError: LocalizedError {
    let message: String

    var errorDescription: String? { message }
}

extension NSError {
    fileprivate var readFailure: ReadFailure? { userInfo["KotlinException"] as? ReadFailure }
}

extension hGraphQL.GraphQLError {
    /// No answer, or no read failure at all, is `.otherError`; an answer the read could not use is `.graphQLError`.
    /// Kotlin has already logged the failure.
    init(readError error: Error) {
        switch (error as NSError).readFailure?.kind {
        case .network?, nil: self = .otherError(error: error)
        default: self = .graphQLError(errors: [])
        }
    }
}
