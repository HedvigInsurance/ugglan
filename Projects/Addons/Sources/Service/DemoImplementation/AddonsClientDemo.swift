public class AddonsClientDemo: AddonsClient {
    public init() {}

    public func getAddon() async throws -> AddonModel {
        let addons: AddonModel =
            .init(
                id: "Reseskydd",
                title: "Reseskydd",
                subTitle: "sub title",
                options: [
                    .init(
                        id: "Reseskydd",
                        title: "Reseskydd",
                        subtitle: "",
                        price: nil,
                        subOptions: []
                    ),
                    .init(
                        id: "Reseskydd Plus",
                        title: "Reseskydd Plus",
                        subtitle: "",
                        price: .init(amount: "79", currency: "SEK"),
                        subOptions: [
                            .init(
                                id: "45",
                                title: "Travel Plus 45 days",
                                subtitle: "40",
                                price: .init(amount: "49", currency: "SEK")
                            ),
                            .init(
                                id: "60",
                                title: "Travel Plus 60 days",
                                subtitle: "60",
                                price: .init(amount: "79", currency: "SEK")
                            ),
                        ]
                    ),
                ]
            )

        return addons
    }

    public func getContract(contractId: String) async throws -> AddonContract {
        let contractData: AddonContract = .init(
            contractId: "contractId",
            displayItems: [
                .init(title: "title1", value: "value1"),
                .init(title: "title2", value: "value2"),
            ],
            documents: [],
            insurableLimits: [
                .init(label: "limit", limit: "", description: "description")
            ],
            typeOfContract: .seApartmentBrf
        )
        return contractData
    }
}
