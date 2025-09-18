import Campaign
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
                        netAmount: .sek(250),
                        grossAmount: .sek(200),
                        discounts: [
                            .init(
                                code: "TOGETHER",
                                displayValue: MonetaryAmount.sek(10).formattedNegativeAmount,
                                description: "15% discount for 12 months",
                                discountId: "TOGETHER",
                                type: .discount(status: .active)
                            )
                        ],
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
                        netAmount: .sek(250),
                        grossAmount: .sek(200),
                        discounts: [
                            .init(
                                code: "TOGETHER",
                                displayValue: MonetaryAmount.sek(10).formattedNegativeAmount,
                                description: "15% discount for 12 months",
                                discountId: "TOGETHER",
                                type: .discount(status: .active)
                            )
                        ],
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
                referralDiscount: nil,
                amountPerReferral: .sek(10),
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
                            netAmount: .sek(250),
                            grossAmount: .sek(200),
                            discounts: [
                                .init(
                                    code: "TOGETHER",
                                    displayValue: MonetaryAmount.sek(10).formattedNegativeAmount,
                                    description: "15% discount for 12 months",
                                    discountId: "TOGETHER",
                                    type: .discount(status: .active)
                                )
                            ],
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
                            netAmount: .sek(250),
                            grossAmount: .sek(200),
                            discounts: [
                                .init(
                                    code: "TOGETHER",
                                    displayValue: MonetaryAmount.sek(10).formattedNegativeAmount,
                                    description: "15% discount for 12 months",
                                    discountId: "TOGETHER",
                                    type: .discount(status: .active)
                                )
                            ],
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
                    referralDiscount: nil,
                    amountPerReferral: .sek(10),
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
                        referralDiscount: nil,
                        amountPerReferral: .sek(10),
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
                        referralDiscount: nil,
                        amountPerReferral: .sek(10),
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
