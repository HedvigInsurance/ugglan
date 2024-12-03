import Foundation

public class AddonsClientDemo: AddonsClient {
    public init() {}

    public func getAddon(contractId: String) async throws -> AddonModel {
        let addons: AddonModel =
            .init(
                id: "Travel Plus",
                title: "Travel Plus",
                description: "Extended travel insurance with extra coverage for your travels",
                tag: "Popular",
                informationText: "Click to learn more about our extended travel coverage Reseskydd Plus",
                activationDate: Date(),
                options: [
                    .init(
                        id: "Travel Plus",
                        title: "Travel Plus",
                        description: "For those who travel often: luggage protection and 24/7 assistance worldwide",
                        price: .init(amount: "79", currency: "SEK"),
                        subOptions: [
                            .init(
                                id: "45",
                                title: "45 days",
                                price: .init(amount: "49", currency: "SEK")
                            ),
                            .init(
                                id: "60",
                                title: "60 days",
                                price: .init(amount: "79", currency: "SEK")
                            ),
                        ]
                    )
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

    public func submitAddon(quoteId: String, addonId: String) async throws {}
}
