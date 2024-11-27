import Foundation
import hCoreUI
import hGraphQL

@MainActor
public protocol AddonsClient {
    func getAddon() async throws -> AddonModel
    func getContract(contractId: String) async throws -> AddonContract
}

public struct AddonContract {
    let contractId: String
    let contractName: String
    let displayItems: [QuoteDisplayItem]
    let documents: [hPDFDocument]
    let insurableLimits: [InsurableLimits]
    let typeOfContract: TypeOfContract?
    let activationDate: Date
    let currentPremium: MonetaryAmount

    public init(
        contractId: String,
        data: OctopusGraphQL.AgreementFragment
    ) {
        self.contractId = contractId
        self.contractName = data.productVariant.displayName
        self.displayItems = data.displayItems.map({ .init(title: $0.displayTitle, value: $0.displayValue) })
        self.documents = data.productVariant.documents.map({
            .init(displayName: $0.displayName, url: $0.url, type: .unknown)
        })
        self.insurableLimits = data.productVariant.insurableLimits.map({ .init($0) })
        self.typeOfContract = TypeOfContract.resolve(for: data.productVariant.typeOfContract)
        self.activationDate = data.activeFrom.localDateToDate ?? Date()
        self.currentPremium = .init(fragment: data.premium.fragments.moneyFragment)
    }

    public init(
        contractId: String,
        contractName: String,
        displayItems: [QuoteDisplayItem],
        documents: [hPDFDocument],
        insurableLimits: [InsurableLimits],
        typeOfContract: TypeOfContract?,
        activationDate: Date,
        currentPremium: MonetaryAmount
    ) {
        self.contractId = contractId
        self.contractName = contractName
        self.displayItems = displayItems
        self.documents = documents
        self.insurableLimits = insurableLimits
        self.typeOfContract = typeOfContract
        self.activationDate = activationDate
        self.currentPremium = currentPremium
    }
}
