import Foundation
import hCore
import hGraphQL

public protocol hPaymentService {
    func getPaymentData() async throws -> PaymentData
    func getPaymentStatusData() async throws -> PaymentStatusData
    func getPaymentDiscountsData() async throws -> PaymentDiscountsData
}

public class hPaymentServiceDemo: hPaymentService {
    public init() {}
    public func getPaymentData() async throws -> PaymentData {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return .init(
            payment: .init(gross: .sek(460), net: .sek(400), date: "2023-11-30"),
            previousPaymentStatus: nil,  //.failedForPrevious(from: "2023-10-11", to: "2023-10-27"),
            contracts: [
                .init(
                    id: "id",
                    title: "Title",
                    subtitle: "Subtitle",
                    amount: .sek(200),
                    periods: [
                        .init(
                            id: "id",
                            from: "2023-11-01",
                            to: "2023-11-30",
                            amount: .sek(200),
                            isOutstanding: false
                        )
                    ]
                ),
                .init(
                    id: "id1",
                    title: "Title 2",
                    subtitle: "Subtitle 2",
                    amount: .sek(200),
                    periods: [
                        .init(
                            id: "id2",
                            from: "2023-11-01",
                            to: "2023-11-30",
                            amount: .sek(100),
                            isOutstanding: false
                        ),
                        .init(
                            id: "id12",
                            from: "2023-10-01",
                            to: "2023-10-31",
                            amount: .sek(100),
                            isOutstanding: true
                        ),
                    ]
                ),
            ],
            discounts: [
                .init(
                    id: "CODE",
                    code: "CODE",
                    amount: .sek(30),
                    title: "15% off for 1 year",
                    listOfAffectedInsurances: [.init(id: "1", displayName: "Car Insurance * ABH 234")],
                    validUntil: "2023-12-10",
                    canBeDeleted: false
                ),
                .init(
                    id: "CODE 2",
                    code: "CODE 2",
                    amount: .sek(30),
                    title: "15% off for 1 year",
                    listOfAffectedInsurances: [.init(id: "1", displayName: "Home insurace &*")],
                    validUntil: "2023-11-03",
                    canBeDeleted: false
                ),
            ],
            paymentDetails: .init(paymentMethod: "Method", account: "Account", bank: "Bank")
        )
    }

    public func getPaymentStatusData() async throws -> PaymentStatusData {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return PaymentStatusData(status: .needsSetup, nextChargeDate: "2023-11-29", displayName: nil, descriptor: nil)
    }

    public func getPaymentDiscountsData() async throws -> PaymentDiscountsData {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return .init(
            discounts: [
                .init(
                    id: "CODE",
                    code: "CODE",
                    amount: .sek(30),
                    title: "15% off for 1 year",
                    listOfAffectedInsurances: [.init(id: "1", displayName: "Car Insurance * ABH 234")],
                    validUntil: "2023-12-10",
                    canBeDeleted: true
                ),
                .init(
                    id: "CODE 2",
                    code: "CODE 2",
                    amount: .sek(30),
                    title: "15% off for 1 year",
                    listOfAffectedInsurances: [.init(id: "1", displayName: "Home insurace &*")],
                    validUntil: "2023-11-03",
                    canBeDeleted: false
                ),
            ],
            referralsData: .init(
                code: "CODE",
                discountPerMember: .sek(10),
                discount: .sek(0),
                referrals: [
                    .init(id: "id1", name: "Name", activeDiscount: .sek(10), status: .active),
                    .init(id: "id2", name: "Name", activeDiscount: .sek(10), status: .active),
                    .init(id: "id3", name: "Name", activeDiscount: .sek(10), status: .active),
                    .init(id: "id4", name: "Name", activeDiscount: .sek(10), status: .active),
                    .init(id: "id5", name: "Name", activeDiscount: .sek(10), status: .active),
                    .init(id: "id6", name: "Name", activeDiscount: .sek(10), status: .active),
                    .init(id: "id7", name: "Name", activeDiscount: .sek(10), status: .active),
                    .init(id: "id8", name: "Name", activeDiscount: .sek(10), status: .active),
                    .init(id: "id9", name: "Name", activeDiscount: .sek(10), status: .active),
                    .init(id: "id10", name: "Name", activeDiscount: .sek(10), status: .active),
                    .init(id: "id11", name: "Name pending", status: .pending),
                    .init(id: "id12", name: "Name terminated", status: .terminated),
                    .init(id: "id13", name: "Name", activeDiscount: .sek(10), status: .active),
                    .init(id: "id14", name: "Name", activeDiscount: .sek(10), status: .active),
                    .init(id: "id15", name: "Name", activeDiscount: .sek(10), status: .active),
                ]
            )
        )
    }

}
