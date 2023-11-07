import Foundation
import hCore
import hGraphQL

public protocol hPaymentService {
    func getPaymentData() async throws -> PaymentData
    func getPaymentStatusData() async throws -> PaymentStatusData
    func getPaymentDiscountsData() async throws -> PaymentDiscountsData
    func getPaymentHistoryData() async throws -> [PaymentHistoryListData]

}

public class hPaymentServiceDemo: hPaymentService {
    public init() {}
    public func getPaymentData() async throws -> PaymentData {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return .init(
            payment: .init(gross: .sek(460), net: .sek(400), date: "2023-11-30"),
            status: .upcoming,
            previousPaymentStatus: nil,
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
                    validUntil: "2023-12-10"
                ),
                .init(
                    id: "CODE 2",
                    code: "CODE 2",
                    amount: .sek(30),
                    title: "15% off for 1 year",
                    listOfAffectedInsurances: [.init(id: "1", displayName: "Home insurace &*")],
                    validUntil: "2023-11-03"
                ),
            ],
            paymentDetails: .init(paymentMethod: "Method", account: "Account", bank: "Bank"),
            addedToThePayment: nil
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
                    validUntil: "2023-12-10"
                ),
                .init(
                    id: "CODE 2",
                    code: "CODE 2",
                    amount: .sek(30),
                    title: "15% off for 1 year",
                    listOfAffectedInsurances: [.init(id: "1", displayName: "Home insurace &*")],
                    validUntil: "2023-11-03"
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
        try await Task.sleep(nanoseconds: 1_000_000_000)
        let item = PaymentHistoryListData(
            id: "2023",
            year: "2023",
            valuesPerMonth: [
                .init(
                    id: "1",
                    date: "2023-03-31",
                    amount: .sek(1531),
                    paymentData: .init(
                        payment: .init(gross: .sek(200), net: .sek(100), date: "2023-10-11"),
                        status: .addedtoFuture(date: "2023-10-01", withId: "Id", isUpcoming: false),
                        previousPaymentStatus: nil,
                        contracts: [
                            .init(
                                id: "ContractId",
                                title: "Contract",
                                subtitle: "Subtitle",
                                amount: .sek(200),
                                periods: [
                                    .init(
                                        id: "periodId",
                                        from: "2023-10-11",
                                        to: "2023-10-12",
                                        amount: .sek(200),
                                        isOutstanding: false
                                    ),
                                    .init(
                                        id: "periodId2",
                                        from: "2023-10-11",
                                        to: "2023-10-12",
                                        amount: .sek(200),
                                        isOutstanding: false
                                    ),
                                ]
                            )
                        ],
                        discounts: [
                            .init(
                                id: "discount1",
                                code: "CODE",
                                amount: .sek(200),
                                title: "TItle",
                                listOfAffectedInsurances: [.init(id: "Id1", displayName: "CarInsurance")],
                                validUntil: "2023-10-11"
                            )
                        ],
                        paymentDetails: .init(paymentMethod: "Autogyro", account: "****123123", bank: "SEB"),
                        addedToThePayment: [
                            .init(
                                payment: .init(gross: .sek(200), net: .sek(100), date: "2023-10-11"),
                                status: .success,
                                previousPaymentStatus: nil,
                                contracts: [
                                    .init(
                                        id: "ContractId",
                                        title: "Contract",
                                        subtitle: "Subtitle",
                                        amount: .sek(200),
                                        periods: [
                                            .init(
                                                id: "periodId",
                                                from: "2023-10-11",
                                                to: "2023-10-12",
                                                amount: .sek(200),
                                                isOutstanding: false
                                            ),
                                            .init(
                                                id: "periodId2",
                                                from: "2023-10-11",
                                                to: "2023-10-12",
                                                amount: .sek(200),
                                                isOutstanding: false
                                            ),
                                        ]
                                    )
                                ],
                                discounts: [
                                    .init(
                                        id: "discount1",
                                        code: "CODE",
                                        amount: .sek(200),
                                        title: "TItle",
                                        listOfAffectedInsurances: [.init(id: "Id1", displayName: "CarInsurance")],
                                        validUntil: "2023-10-11"
                                    )
                                ],
                                paymentDetails: .init(paymentMethod: "Autogyro", account: "****123123", bank: "SEB"),
                                addedToThePayment: nil
                            )
                        ]
                    )
                ),
                .init(
                    id: "2",
                    date: "2023-04-30",
                    amount: .sek(1531),
                    paymentData: .init(
                        payment: .init(gross: .sek(200), net: .sek(100), date: "2023-10-11"),
                        status: .success,
                        previousPaymentStatus: nil,
                        contracts: [],
                        discounts: [],
                        paymentDetails: nil,
                        addedToThePayment: nil
                    )
                ),
            ]
        )
        return [item]
    }
}
