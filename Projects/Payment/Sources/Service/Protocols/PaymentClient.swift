import Foundation

@MainActor
public protocol hPaymentClient: Sendable {
    func getPaymentData() async throws -> (upcoming: PaymentData?, ongoing: [PaymentData])
    func getPaymentStatusData() async throws -> PaymentStatusData
    func getPaymentNoticeData() async throws -> PaymentNoticeData
    func getPaymentHistoryData() async throws -> [PaymentHistoryListData]
    func getMissedPaymentData() async throws -> MissedPaymentData?
    func setupPaymentMethod(_ type: PaymentMethodSetupType) async throws -> PaymentSetupResult
    func getPaymentSetupStatus(orderId: String) async throws -> PaymentSetupResult.PaymentSetupStatus
    func chargeOutstandingPayment() async throws
    func setDefaultPaymentMethod(_ method: PaymentMethod) async throws
    func removePaymentMethod(_ provider: PaymentProvider) async throws
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
