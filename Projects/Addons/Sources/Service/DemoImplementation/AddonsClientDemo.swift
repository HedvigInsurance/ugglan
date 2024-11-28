import Foundation

public class AddonsClientDemo: AddonsClient {
    public init() {}

    public func getAddon() async throws -> AddonModel {
        let addons: AddonModel =
            .init(
                id: "Reseskydd",
                title: "Reseskydd",
                subTitle: "sub title",
                informationText: "Click to learn more about our extended travel coverage Reseskydd Plus",
                options: [
                    .init(
                        id: "Reseskydd",
                        title: "Reseskydd",
                        subtitle: "",
                        price: nil,
                        subOptions: [],
                        isAlreadyIncluded: true
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
                        ],
                        isAlreadyIncluded: false
                    ),
                ]
            )

        return addons
    }

    public func getContract(contractId: String) async throws -> AddonContract {
        let contractData: AddonContract = .init(
            contractId: "contractId",
            contractName: "Reseskydd plus",
            displayItems: [
                .init(title: "title1", value: "value1"),
                .init(title: "title2", value: "value2"),
            ],
            documents: [],
            insurableLimits: [
                .init(label: "limit", limit: "", description: "description")
            ],
            typeOfContract: .seApartmentBrf,
            activationDate: Date(),
            currentPremium: .init(amount: "220", currency: "SEK")
        )
        return contractData
    }
}
