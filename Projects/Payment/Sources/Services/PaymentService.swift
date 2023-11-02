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
            upcomingPayment: .init(gross: .sek(100), net: .sek(80), date: "2023-11-29"),
            previousPaymentStatus: .pending,
            contracts: [],
            discounts: [
                .init(
                    code: "CODE",
                    amount: .sek(100),
                    title: "15% off for 1 year",
                    subtitle: "Car Insurance * ABH 234",
                    validUntil: "2023-12-10"
                )
            ]
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
        return .init(
            upcomingPayment: .init(gross: .sek(100), net: .sek(80), date: "2023-11-29"),
            previousPaymentStatus: .pending,
            contracts: [],
            discounts: [
                .init(
                    code: "CODE",
                    amount: .sek(100),
                    title: "15% off for 1 year",
                    subtitle: "Car Insurance * ABH 234",
                    validUntil: "2023-12-10"
                )
            ]
        )
    }

    public func getPaymentStatusData() async throws -> PaymentStatusData {
        return PaymentStatusData(status: .needsSetup, nextChargeDate: "2023-11-29", displayName: nil, descriptor: nil)
    }

}
