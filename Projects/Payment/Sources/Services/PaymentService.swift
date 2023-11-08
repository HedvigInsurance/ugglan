import Foundation
import hCore
import hGraphQL

public protocol hPaymentService {
    func getPaymentData() async throws -> PaymentData
    func getPaymentStatusData() async throws -> PaymentStatusData
}

public class hPaymentServiceOctopus: hPaymentService {
    @Inject var octopus: hOctopus

    public init() {}
    public func getPaymentData() async throws -> PaymentData {
        let data = try await octopus.client.fetch(
            query: OctopusGraphQL.PaymentDataQuery(),
            cachePolicy: .fetchIgnoringCacheCompletely
        )

        return .init(
            upcomingPayment: .init(amount: .init(amount: "100", currency: ""), date: ""),
            previousPaymentStatus: .pending
        )
    }

    public func getPaymentStatusData() async throws -> PaymentStatusData {
        let data = try await octopus.client.fetch(
            query: OctopusGraphQL.PaymentInformationQuery(),
            cachePolicy: .fetchIgnoringCacheCompletely
        )
        return .init(data: data)
    }
}

public class hPaymentServiceDemo: hPaymentService {

    public init() {}
    public func getPaymentData() async throws -> PaymentData {
        return PaymentData(
            upcomingPayment: .init(
                amount: .sek(200),
                date: "2023-11-29"
            ),
            previousPaymentStatus: .failed(from: "2023-10-10", to: "2023-11-10")
        )
    }

    public func getPaymentStatusData() async throws -> PaymentStatusData {
        return PaymentStatusData(status: .needsSetup, nextChargeDate: "2023-11-29", displayName: nil, descriptor: nil)
    }

}
