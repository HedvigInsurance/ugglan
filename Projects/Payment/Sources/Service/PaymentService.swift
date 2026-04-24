import Apollo
import AutomaticLog
import Foundation
import hCore

@MainActor
public class hPaymentService {
    @Inject var client: hPaymentClient

    @Log(.error)
    func getPaymentData() async throws -> (upcoming: PaymentData?, ongoing: [PaymentData?]) {
        try await client.getPaymentData()
    }

    @Log(.error)
    public func getPaymentStatusData() async throws -> PaymentStatusData {
        try await client.getPaymentStatusData()
    }

    @Log(.error)
    public func getPaymentHistoryData() async throws -> [PaymentHistoryListData] {
        try await client.getPaymentHistoryData()
    }

    @Log(.error)
    public func getConnectPaymentUrl() async throws -> URL {
        try await client.getConnectPaymentUrl()
    }

    @Log(.error)
    public func chargeOutstandingPayment() async throws {
        try await client.chargeOutstandingPayment()
    }
}
