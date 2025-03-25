import Foundation
import hCore
import hGraphQL

@MainActor
public protocol hCampaignClient {
    func remove(codeId: String) async throws
    func add(code: String) async throws
}

enum CampaignError: Error {
    case userError(message: String)
    case notImplemented
}

extension CampaignError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .userError(message):
            return message
        case .notImplemented:
            return L10n.General.errorBody
        }
    }
}
