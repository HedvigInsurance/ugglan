import Foundation
import hCore

public class FetchContractsClientDemo: FetchContractsClient {
    public init() {}
    public func getContracts() async throws -> ContractsStack {
        let variant = ProductVariant(
            termsVersion: "",
            typeOfContract: Contract.TypeOfContract.seApartmentRent.rawValue,
            partner: nil,
            perils: [],
            insurableLimits: [
                .init(
                    label: "Your things are insured at",
                    limit: "1 000 000 SEK",
                    description: "All your possessions are together insured up to 1 000 000 SEK."
                ),
                .init(
                    label: "Deductible",
                    limit: "1 750 kr",
                    description: "Deductible is the cost of an claim that you have to cover yourself."
                ),
                .init(
                    label: "Travel insurance",
                    limit: "45 days",
                    description:
                        "Travel insurance covers you during the first 45 days of your trip and is valid worldwide."
                ),
            ],
            documents: [.init(displayName: "Display name", url: "https://www.hedvig.com", type: .generalTerms)],
            displayName: "Home Insurance Rent",
            displayNameTier: "Standard",
            tierDescription: "Vårt mellanpaket med hög ersättning."
        )
        let agreement = Agreement(
            certificateUrl: nil,
            activeFrom: Date().addingTimeInterval(.days(numberOfDays: -1)).localDateString,
            activeTo: nil,
            premium: .sek(200),
            displayItems: [
                .init(title: "Apartment type", value: "Rental"),
                .init(title: "Street", value: "Stopvägen 59"),
                .init(title: "Postal code", value: "11685"),
                .init(title: "City", value: "Stockholm"),
                .init(title: "Living area", value: "56 m²"),
                .init(title: "Insured people", value: "Only you"),
            ],
            productVariant: variant
        )
        let contract = Contract(
            id: "contractId",
            currentAgreement: agreement,
            exposureDisplayName: "Stopvägen 59",
            masterInceptionDate: "",
            terminationDate: nil,
            supportsAddressChange: false,
            supportsCoInsured: false,
            supportsTravelCertificate: false,
            supportsChangeTier: false,
            upcomingChangedAgreement: nil,
            upcomingRenewal: nil,
            firstName: "",
            lastName: "",
            ssn: nil,
            typeOfContract: Contract.TypeOfContract.seHouse,
            coInsured: []
        )
        return .init(activeContracts: [contract], pendingContracts: [], terminatedContracts: [])
    }

    public func getCrossSell() async throws -> [CrossSell] {
        if let url = URL(string: "") {
            return [CrossSell(title: "", description: "", imageURL: url, blurHash: "", typeOfContract: "", type: .home)]
        }
        return []
    }
}
