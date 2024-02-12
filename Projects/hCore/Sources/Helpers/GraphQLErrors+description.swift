import Foundation
import hGraphQL

extension hGraphQL.GraphQLError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .graphQLError(let errors):
            return L10n.somethingWentWrong
        case .otherError:
            return L10n.General.errorBody
        }
    }
}
