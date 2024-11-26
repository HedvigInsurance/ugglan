import hCore
@preconcurrency import hGraphQL

public class AddonsClientOctopus: AddonsClient {
    @Inject @preconcurrency var octopus: hOctopus

    public init() {}

    public func getAddons() throws -> [AddonModel] {
        let addons: [AddonModel] = [
            .init(title: "Reseskydd", subTitle: nil, tag: "Ingår", coverageDays: nil),
            .init(
                title: "Reseskydd Plus",
                subTitle: "För dig som reser mycket, bagageskydd, hjälp överallt i världen 24/7.",
                tag: "+ 49 kr/mo",
                coverageDays: [
                    .init(nbOfDays: 45, title: "Travel Plus 45 days", price: 49),
                    .init(nbOfDays: 60, title: "Travel Plus 60 days", price: 79),
                ]
            ),
        ]

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
