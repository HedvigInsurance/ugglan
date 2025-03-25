import Foundation

@MainActor
public protocol hPaymentClient {
    func getPaymentData() async throws -> (upcoming: PaymentData?, ongoing: [PaymentData])
    func getPaymentStatusData() async throws -> PaymentStatusData
    func getPaymentHistoryData() async throws -> [PaymentHistoryListData]
    func getConnectPaymentUrl() async throws -> URL
}

enum PaymentError: Error {
    case missingDataError(message: String)
}

extension PaymentError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .missingDataError(message): return message
        }
    }
}
