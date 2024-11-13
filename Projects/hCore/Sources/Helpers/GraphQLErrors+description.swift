import Foundation
import hGraphQL

@MainActor
extension hGraphQL.GraphQLError: @retroactive @preconcurrency LocalizedError {
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
