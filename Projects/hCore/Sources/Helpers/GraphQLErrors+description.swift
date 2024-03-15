import Foundation
import hGraphQL

extension hGraphQL.GraphQLError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .graphQLError(let errors):
            let messages = errors.map { $0.localizedDescription }
            return messages.joined(separator: " ")
        case .otherError:
            return L10n.General.errorBody
        }
    }
}
