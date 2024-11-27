import Foundation
import hGraphQL

@MainActor
extension hGraphQL.GraphQLError: @retroactive @preconcurrency LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .graphQLError(let errors):
            return L10n.General.errorBody
        case .otherError:
            return L10n.General.errorBody
        }
    }
}
