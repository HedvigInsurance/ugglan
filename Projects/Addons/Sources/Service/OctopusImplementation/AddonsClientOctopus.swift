import hCore
import hGraphQL

public class AddonsClientOctopus: AddonsClient {
    @Inject var octopus: hOctopus

    public init() {}

    public func getAddon() async throws -> AddonModel {
        let addons: AddonModel =
            .init(
                id: "Reseskydd",
                title: "Reseskydd",
                subTitle: "sub title",
                informationText: "information text",
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
        let contractsQuery = OctopusGraphQL.GetContractForAddonQuery(contractId: contractId)

        let contractResponse = try await octopus.client.fetch(
            query: contractsQuery,
            cachePolicy: .fetchIgnoringCacheCompletely
        )

        let contract = contractResponse.contract

        let contractData: AddonContract = .init(
            contractId: contractId,
            data: contract.currentAgreement.fragments.agreementFragment
        )
        return contractData
    }
}
