public class hCampaignClientDemo: hCampaignClient {
    public init() {}

    public func getPaymentDiscountsData() async throws -> PaymentDiscountsData {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return .init(
            discounts: [
                .init(
                    code: "CODE",
                    amount: .sek(30),
                    title: "15% off for 1 year",
                    listOfAffectedInsurances: [.init(id: "1", displayName: "Car Insurance * ABH 234")],
                    validUntil: "2023-12-10",
                    canBeDeleted: true,
                    discountId: "CODE"
                ),
                .init(
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
                    .init(
                        id: "id1",
                        name: "Name",
                        code: "CODE",
                        description: "desc",
                        activeDiscount: .sek(10),
                        status: .active
                    ),
                    .init(
                        id: "id2",
                        name: "Name",
                        code: "CODE",
                        description: "desc",
                        activeDiscount: .sek(10),
                        status: .active
                    ),
                    .init(
                        id: "id3",
                        name: "Name",
                        code: "CODE",
                        description: "desc",
                        activeDiscount: .sek(10),
                        status: .active
                    ),
                    .init(
                        id: "id4",
                        name: "Name",
                        code: "CODE",
                        description: "desc",
                        activeDiscount: .sek(10),
                        status: .active
                    ),
                    .init(
                        id: "id5",
                        name: "Name",
                        code: "CODE",
                        description: "desc",
                        activeDiscount: .sek(10),
                        status: .active
                    ),
                    .init(
                        id: "id6",
                        name: "Name",
                        code: "CODE",
                        description: "desc",
                        activeDiscount: .sek(10),
                        status: .active
                    ),
                    .init(
                        id: "id7",
                        name: "Name",
                        code: "CODE",
                        description: "desc",
                        activeDiscount: .sek(10),
                        status: .active
                    ),
                    .init(
                        id: "id8",
                        name: "Name",
                        code: "CODE",
                        description: "desc",
                        activeDiscount: .sek(10),
                        status: .active
                    ),
                    .init(
                        id: "id9",
                        name: "Name",
                        code: "CODE",
                        description: "desc",
                        activeDiscount: .sek(10),
                        status: .active
                    ),
                    .init(
                        id: "id10",
                        name: "Name",
                        code: "CODE",
                        description: "desc",
                        activeDiscount: .sek(10),
                        status: .active
                    ),
                    .init(id: "id11", name: "Name pending", code: "CODE", description: "desc", status: .pending),
                    .init(id: "id12", name: "Name terminated", code: "CODE", description: "desc", status: .terminated),
                    .init(
                        id: "id13",
                        name: "Name",
                        code: "CODE",
                        description: "desc",
                        activeDiscount: .sek(10),
                        status: .active
                    ),
                    .init(
                        id: "id14",
                        name: "Name",
                        code: "CODE",
                        description: "desc",
                        activeDiscount: .sek(10),
                        status: .active
                    ),
                    .init(
                        id: "id15",
                        name: "Name",
                        code: "CODE",
                        description: "desc",
                        activeDiscount: .sek(10),
                        status: .active
                    ),
                ]
            )
        )
    }
}
