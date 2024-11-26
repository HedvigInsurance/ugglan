public class AddonsClientDemo: AddonsClient {
    public init() {}

    public func getAddons() async throws -> AddonModel {
        let addons: AddonModel =
            .init(
                title: "Reseskydd",
                subTitle: "sub title",
                options: [
                    .init(
                        title: "reseskydd",
                        subtitle: "",
                        price: nil,
                        subOptions: []
                    ),
                    .init(
                        title: "Reseskydd Plus",
                        subtitle: "",
                        price: .init(amount: "79", currency: "SEK"),
                        subOptions: [
                            .init(
                                title: "Travel Plus 45 days",
                                subtitle: "subtitle",
                                price: .init(amount: "49", currency: "SEK")
                            ),
                            .init(
                                title: "Travel Plus 60 days",
                                subtitle: "subtitle",
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
