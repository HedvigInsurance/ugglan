import Foundation
import hCore

@MainActor
public protocol hCampaignClient {
    func getPaymentDiscountsData() async throws -> PaymentDiscountsData
}

public enum CampaignError: Error {
    case userError(message: String)
    case notImplemented
}

extension CampaignError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .userError(message):
            return message
        case .notImplemented:
            return L10n.General.errorBody
        }
    }
}
