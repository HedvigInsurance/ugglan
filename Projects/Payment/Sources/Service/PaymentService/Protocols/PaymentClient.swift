import Foundation

public protocol hPaymentClient {
    func getPaymentData() async throws -> PaymentData?
    func getPaymentStatusData() async throws -> PaymentStatusData
    func getPaymentDiscountsData() async throws -> PaymentDiscountsData
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
