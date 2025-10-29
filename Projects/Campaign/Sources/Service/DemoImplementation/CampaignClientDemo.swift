public class hCampaignClientDemo: hCampaignClient {
    public init() {}

    public func getPaymentDiscountsData() async throws -> PaymentDiscountsData {
        try await Task.sleep(seconds: 1)
        return .init(
            discountsData: [
                .init(
                    id: "id",
                    displayName: "Insurance",
                    info: nil,
                    discounts: [
                        .init(
                            code: "CODE",
                            displayValue: "-30 kr/mo",
                            description: "15% off for 1 year",
                            type: .discount(status: .terminated)
                        )
                    ]
                )

            ],
            referralsData: .init(
                discountPerMember: .sek(10),
                referrals: [
                    .init(
                        id: "id1",
                        name: "Name",
                        code: "CODE",
                        description: "desc",
                        activeDiscount: .sek(10)
                    ),
                    .init(
                        id: "id2",
                        name: "Name",
                        code: "CODE",
                        description: "desc",
                        activeDiscount: .sek(10)
                    ),
                    .init(
                        id: "id3",
                        name: "Name",
                        code: "CODE",
                        description: "desc",
                        activeDiscount: .sek(10)
                    ),
                    .init(
                        id: "id4",
                        name: "Name",
                        code: "CODE",
                        description: "desc",
                        activeDiscount: .sek(10)
                    ),
                    .init(
                        id: "id5",
                        name: "Name",
                        code: "CODE",
                        description: "desc",
                        activeDiscount: .sek(10)
                    ),
                    .init(
                        id: "id6",
                        name: "Name",
                        code: "CODE",
                        description: "desc",
                        activeDiscount: .sek(10)
                    ),
                    .init(
                        id: "id7",
                        name: "Name",
                        code: "CODE",
                        description: "desc",
                        activeDiscount: .sek(10)
                    ),
                    .init(
                        id: "id8",
                        name: "Name",
                        code: "CODE",
                        description: "desc",
                        activeDiscount: .sek(10)
                    ),
                    .init(
                        id: "id9",
                        name: "Name",
                        code: "CODE",
                        description: "desc",
                        activeDiscount: .sek(10)
                    ),
                    .init(
                        id: "id10",
                        name: "Name",
                        code: "CODE",
                        description: "desc",
                        activeDiscount: .sek(10)
                    ),
                    .init(id: "id11", name: "Name pending", code: "CODE", description: "desc"),
                    .init(id: "id12", name: "Name terminated", code: "CODE", description: "desc"),
                    .init(
                        id: "id13",
                        name: "Name",
                        code: "CODE",
                        description: "desc",
                        activeDiscount: .sek(10)
                    ),
                    .init(
                        id: "id14",
                        name: "Name",
                        code: "CODE",
                        description: "desc",
                        activeDiscount: .sek(10)
                    ),
                    .init(
                        id: "id15",
                        name: "Name",
                        code: "CODE",
                        description: "desc",
                        activeDiscount: .sek(10)
                    ),
                ]
            )
        )
    }
}
