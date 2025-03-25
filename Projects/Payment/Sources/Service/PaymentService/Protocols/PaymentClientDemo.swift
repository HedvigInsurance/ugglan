import Foundation
import hCore

public class hPaymentClientDemo: hPaymentClient {
    public init() {}
    public func getPaymentData() async throws -> (upcoming: PaymentData?, ongoing: [PaymentData]) {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return (
            .init(
                id: "",
                payment: .init(
                    gross: .sek(400),
                    net: .sek(370),
                    carriedAdjustment: nil,
                    settlementAdjustment: nil,
                    date: "2025-02-27"
                ),
                status: .upcoming,
                contracts: [
                    .init(
                        id: "id",
                        title: "Hemförsäkring Bostadsrätt Standard",
                        subtitle: "Bastugatan 25 ∙ Bara du",
                        amount: .sek(200),
                        periods: [
                            .init(
                                id: "id",
                                from: "2025-02-01",
                                to: "2023-02-28",
                                amount: .sek(200),
                                isOutstanding: false,
                                desciption: nil
                            )
                        ]
                    ),
                    .init(
                        id: "id1",
                        title: "Kattförsäkring Basic",
                        subtitle: "Lola ∙ Huskatt/blandras",
                        amount: .sek(200),
                        periods: [
                            .init(
                                id: "id2",
                                from: "2025-02-01",
                                to: "2023-02-28",
                                amount: .sek(200),
                                isOutstanding: false,
                                desciption: nil
                            )
                        ]
                    ),
                ],
                discounts: [
                    .init(
                        id: "CODE 2",
                        code: "CODE 2",
                        amount: .sek(30),
                        title: "15% off for 1 year",
                        listOfAffectedInsurances: [.init(id: "1", displayName: "Bastugatan 25 ∙ Bara du")],
                        validUntil: "2025-12-31",
                        canBeDeleted: false,
                        discountId: "CODE 2"
                    )
                ],
                paymentDetails: .init(paymentMethod: "Autogiro", account: "****124124", bank: "Handelsbanken"),
                addedToThePayment: nil
            ),
            [
                .init(
                    id: "ongoing",
                    payment: .init(
                        gross: .sek(400),
                        net: .sek(370),
                        carriedAdjustment: nil,
                        settlementAdjustment: nil,
                        date: "2025-01-27"
                    ),
                    status: .pending,
                    contracts: [
                        .init(
                            id: "id",
                            title: "Hemförsäkring Bostadsrätt Standard",
                            subtitle: "Bastugatan 25 ∙ Bara du",
                            amount: .sek(200),
                            periods: [
                                .init(
                                    id: "id",
                                    from: "2025-01-01",
                                    to: "2023-01-31",
                                    amount: .sek(200),
                                    isOutstanding: false,
                                    desciption: nil
                                )
                            ]
                        ),
                        .init(
                            id: "id1",
                            title: "Kattförsäkring Basic",
                            subtitle: "Lola ∙ Huskatt/blandras",
                            amount: .sek(200),
                            periods: [
                                .init(
                                    id: "id2",
                                    from: "2025-01-01",
                                    to: "2023-01-31",
                                    amount: .sek(200),
                                    isOutstanding: false,
                                    desciption: nil
                                )
                            ]
                        ),
                    ],
                    discounts: [
                        .init(
                            id: "CODE 2",
                            code: "CODE 2",
                            amount: .sek(30),
                            title: "15% off for 1 year",
                            listOfAffectedInsurances: [.init(id: "1", displayName: "Bastugatan 25 ∙ Bara du")],
                            validUntil: "2025-12-31",
                            canBeDeleted: false,
                            discountId: "CODE 2"
                        )
                    ],
                    paymentDetails: nil,
                    addedToThePayment: nil
                )
            ]
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
                    id: "CODE 2",
                    code: "CODE",
                    amount: .sek(30),
                    title: "15% off for 1 year",
                    listOfAffectedInsurances: [.init(id: "1", displayName: "Car Insurance * ABH 234")],
                    validUntil: "2023-12-10",
                    canBeDeleted: true,
                    discountId: "CODE"
                ),
                .init(
                    id: "CODE 2",
                    code: "CODE 2",
                    amount: .sek(30),
                    title: "15% off for 1 year",
                    listOfAffectedInsurances: [.init(id: "1", displayName: "Home insurace &*")],
                    validUntil: "2023-11-03",
                    canBeDeleted: false,
                    discountId: "CODE 2"
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
