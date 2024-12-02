import Foundation
import hCore
import hGraphQL

@MainActor
public class AddonsService {
    @Inject var service: AddonsClient

    public func getAddon() async throws -> AddonModel {
        log.info("AddonsService: getAddon", error: nil, attributes: nil)
        return try await service.getAddon()
    }

    public func getContract(contractId: String) async throws -> AddonContract {
        log.info("AddonsService: getContract", error: nil, attributes: nil)
        return try await service.getContract(contractId: contractId)
    }

    public func submitAddon() async throws {
        log.info("AddonsService: submitAddon", error: nil, attributes: nil)
        return try await service.submitAddon()
    }
}

public class AddonsClientOctopus: AddonsClient {
    @Inject var octopus: hOctopus

    public init() {}

    public func getAddon() async throws -> AddonModel {
        let addons: AddonModel =
            .init(
                id: "Travel Plus",
                title: "Travel Plus",
                subTitle: "Extended travel insurance with extra coverage for your travels",
                tag: "Popular",
                informationText: "Click to learn more about our extended travel coverage Reseskydd Plus",
                options: [
                    .init(
                        id: "Travel Plus",
                        title: "Travel Plus",
                        subtitle: "For those who travel often: luggage protection and 24/7 assistance worldwide",
                        price: .init(amount: "79", currency: "SEK"),
                        subOptions: [
                            .init(
                                id: "45",
                                title: "45 days",
                                subtitle: nil,
                                price: .init(amount: "49", currency: "SEK")
                            ),
                            .init(
                                id: "60",
                                title: "60 days",
                                subtitle: nil,
                                price: .init(amount: "79", currency: "SEK")
                            ),
                        ],
                        isAlreadyIncluded: false
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

    public func submitAddon() async throws {}
}
