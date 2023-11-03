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
        return .init(
            payment: .init(gross: .sek(100), net: .sek(80), date: "2023-11-29"),
            previousPaymentStatus: .pending,
            contracts: [],
            discounts: [
                .init(
                    id: "CODE",
                    code: "CODE",
                    amount: .sek(100),
                    title: "15% off for 1 year",
                    listOfAffectedInsurances: [.init(id: "1", displayName: "Car Insurance * ABH 234")],
                    validUntil: "2023-12-10",
                    isValid: true
                )
            ],
            paymentDetails: nil
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
            payment: .init(gross: .sek(100), net: .sek(80), date: "2023-11-29"),
            previousPaymentStatus: .failedForPrevious(from: "2023-10-11", to: "2023-10-27"),
            contracts: [
                .init(
                    id: "id",
                    title: "title",
                    subtitle: "subtitle",
                    amount: .sek(100),
                    periods: [
                        .init(
                            id: "id",
                            from: "2023-11-10",
                            to: "2023-11-23",
                            amount: .sek(200),
                            isOutstanding: false
                        )
                    ]
                )
            ],
            discounts: [
                .init(
                    id: "CODE",
                    code: "CODE",
                    amount: .sek(100),
                    title: "15% off for 1 year",
                    listOfAffectedInsurances: [.init(id: "1", displayName: "Car Insurance * ABH 234")],
                    validUntil: "2023-12-10",
                    isValid: true
                )
            ],
            paymentDetails: .init(paymentMethod: "Method", account: "Account", bank: "Bank")
        )
    }

    public func getPaymentStatusData() async throws -> PaymentStatusData {
        return PaymentStatusData(status: .needsSetup, nextChargeDate: "2023-11-29", displayName: nil, descriptor: nil)
    }

}
