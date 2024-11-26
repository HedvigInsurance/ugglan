public class AddonsClientDemo: AddonsClient {
    public init() {}

    public func getAddons() async throws -> [AddonModel] {
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
