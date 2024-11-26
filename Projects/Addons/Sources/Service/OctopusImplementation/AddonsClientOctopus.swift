import hCore
@preconcurrency import hGraphQL

public class AddonsClientOctopus: AddonsClient {
    @Inject @preconcurrency var octopus: hOctopus

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
                                subtitle: "45",
                                price: .init(amount: 49, currency: "SEK")
                            ),
                            .init(
                                title: "Travel Plus 60 days",
                                subtitle: "60",
                                price: .init(amount: 79, currency: "SEK")
                            ),
                        ]
                    ),
                ]
            )

        return addons
    }

    public func getContract(contractId: String) async throws -> AddonContract {
        let contractsQuery = OctopusGraphQL.GetContractQuery(contractId: contractId)

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
