import Campaign
import Foundation

@MainActor
public protocol hPaymentClient {
    func getPaymentData() async throws -> (upcoming: PaymentData?, ongoing: [PaymentData])
    func getPaymentStatusData() async throws -> PaymentStatusData
    func getPaymentHistoryData() async throws -> [PaymentHistoryListData]
    func getConnectPaymentUrl() async throws -> URL
}

public enum PaymentError: Error {
    case missingDataError(message: String)
}

extension PaymentError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .missingDataError(message): return message
        }
    }
}
