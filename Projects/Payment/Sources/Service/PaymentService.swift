import Apollo
import Foundation
import hCore

@MainActor
public class hPaymentService {
    @Inject var client: hPaymentClient

    func getPaymentData() async throws -> (upcoming: PaymentData?, ongoing: [PaymentData?]) {
        log.info("hPaymentService: getPaymentData", error: nil, attributes: nil)
        return try await client.getPaymentData()
    }

    public func getPaymentStatusData() async throws -> PaymentStatusData {
        log.info("hPaymentService: getPaymentStatusData", error: nil, attributes: nil)
        return try await client.getPaymentStatusData()
    }

    public func getPaymentHistoryData() async throws -> [PaymentHistoryListData] {
        log.info("hPaymentService: getPaymentHistoryData", error: nil, attributes: nil)
        return try await client.getPaymentHistoryData()
    }

    public func getConnectPaymentUrl() async throws -> URL {
        log.info("hPaymentService: getConnectPaymentUrl", error: nil, attributes: nil)
        return try await client.getConnectPaymentUrl()
    }
}
