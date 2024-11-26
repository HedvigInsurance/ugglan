import hCoreUI
import hGraphQL

public protocol AddonsClient {
    func getAddons() async throws -> [AddonModel]
    func getContract(contractId: String) async throws -> AddonContract
}

public struct AddonContract {
    let contractId: String
    let displayItems: [QuoteDisplayItem]
    let documents: [hPDFDocument]
    let insurableLimits: [InsurableLimits]
    let typeOfContract: TypeOfContract?

    public init(
        contractId: String,
        data: OctopusGraphQL.AgreementFragment
    ) {
        self.contractId = contractId
        self.displayItems = data.displayItems.map({ .init(title: $0.displayTitle, value: $0.displayValue) })
        self.documents = data.productVariant.documents.map({
            .init(displayName: $0.displayName, url: $0.url, type: .unknown)
        })
        self.insurableLimits = data.productVariant.insurableLimits.map({ .init($0) })
        self.typeOfContract = TypeOfContract.resolve(for: data.productVariant.typeOfContract)
    }

    public init(
        contractId: String,
        displayItems: [QuoteDisplayItem],
        documents: [hPDFDocument],
        insurableLimits: [InsurableLimits],
        typeOfContract: TypeOfContract?
    ) {
        self.contractId = contractId
        self.displayItems = displayItems
        self.documents = documents
        self.insurableLimits = insurableLimits
        self.typeOfContract = typeOfContract
    }
}
