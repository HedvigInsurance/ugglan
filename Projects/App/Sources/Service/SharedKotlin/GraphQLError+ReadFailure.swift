import Foundation
@preconcurrency import HedvigShared
import hGraphQL

extension hGraphQL.GraphQLError {
    /// What an Octopus client throws for the same failure, so a feature handles a failed Kotlin read like any other
    /// query: no answer, or no read failure at all (a cancellation, say), is `.otherError`; an answer the read could not
    /// use, a rejected token included, is `.graphQLError`. Kotlin has already logged the failure.
    init(readError error: Error) {
        let failure = (error as NSError).userInfo["KotlinException"] as? ReadFailure
        switch failure?.kind {
        case .network?, nil: self = .otherError(error: error)
        default: self = .graphQLError(errors: [])
        }
    }
}
