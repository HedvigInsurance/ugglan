import Foundation
import hGraphQL

@MainActor
extension hGraphQL.GraphQLError: @preconcurrency @retroactive LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .graphQLError:
            return L10n.General.defaultError
        case .otherError:
            return L10n.General.errorBody
        }
    }
}
