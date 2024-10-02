import Foundation
import hCore

public class hPaymentClientDemo: hPaymentClient {
    public init() {}
    public func getPaymentData() async throws -> PaymentData? {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return .init(
            id: "",
            payment: .init(
                gross: .sek(460),
                net: .sek(400),
                carriedAdjustment: nil,
                settlementAdjustment: nil,
                date: "2023-11-30"
            ),
            status: .upcoming,
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
                            isOutstanding: false,
                            desciption: nil
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
                            isOutstanding: false,
                            desciption: nil
                        ),
                        .init(
                            id: "id12",
                            from: "2023-10-01",
                            to: "2023-10-31",
                            amount: .sek(100),
                            isOutstanding: true,
                            desciption: nil
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
            paymentDetails: .init(paymentMethod: "Method", account: "Account", bank: "Bank"),
            addedToThePayment: nil
        )
    }

    public func getPaymentStatusData() async throws -> PaymentStatusData {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return PaymentStatusData(
            status: .noNeedToConnect,
            displayName: "Connected bank",
            descriptor: "****1234"
        )
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
    public func getPaymentHistoryData() async throws -> [PaymentHistoryListData] {
        let success = PaymentHistoryListData(
            id: "2023",
            year: "2023",
            valuesPerMonth: [
                .init(
                    id: "id1",
                    paymentData: .init(
                        id: "idI1",
                        payment: .init(
                            gross: .sek(20),
                            net: .sek(18),
                            carriedAdjustment: nil,
                            settlementAdjustment: nil,
                            date: "2023-11-11"
                        ),
                        status: .success,
                        contracts: [],
                        discounts: [],
                        paymentDetails: nil,
                        addedToThePayment: nil
                    )
                )
            ]
        )
        let failed = PaymentHistoryListData(
            id: "2023",
            year: "2023",
            valuesPerMonth: [
                .init(
                    id: "id1",
                    paymentData: .init(
                        id: "idI1",
                        payment: .init(
                            gross: .sek(20),
                            net: .sek(18),
                            carriedAdjustment: nil,
                            settlementAdjustment: nil,
                            date: "2023-11-11"
                        ),
                        status: .addedtoFuture(date: "2023-12-12"),
                        contracts: [],
                        discounts: [],
                        paymentDetails: nil,
                        addedToThePayment: nil
                    )
                )
            ]
        )
        return [success, failed]
    }

    public func getConnectPaymentUrl() async throws -> URL {
        throw PaymentError.missingDataError(message: L10n.General.errorBody)
    }
}
