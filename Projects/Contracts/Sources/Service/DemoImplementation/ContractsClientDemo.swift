import Addons
import Foundation
import hCore
import hCoreUI

public class FetchContractsClientDemo: FetchContractsClient {
    public init() {}
    public func getContracts() async throws -> ContractsStack {
        let variant = ProductVariant(
            termsVersion: "",
            typeOfContract: TypeOfContract.seApartmentRent.rawValue,
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
            id: UUID().uuidString,
            certificateUrl: nil,
            agreementDate: .init(
                activeFrom: Date().addingTimeInterval(.days(numberOfDays: -1)).localDateString,
                activeTo: nil
            ),
            basePremium: .sek(200),
            itemCost: .init(premium: .init(gross: .sek(200), net: .sek(200)), discounts: []),
            displayItems: [
                .init(title: "Apartment type", value: "Rental"),
                .init(title: "Street", value: "Stopvägen 59"),
                .init(title: "Postal code", value: "11685"),
                .init(title: "City", value: "Stockholm"),
                .init(title: "Living area", value: "56 m²"),
                .init(title: "Insured people", value: "Only you"),
            ],
            productVariant: variant,
            addonVariant: []
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
            typeOfContract: TypeOfContract.seHouse,
            coInsured: []
        )
        return .init(activeContracts: [contract], pendingContracts: [], terminatedContracts: [])
    }

    public func getAddonBannerModel(source _: AddonSource) async throws -> AddonBannerModel? {
        let bannerData = AddonBannerModel(
            contractIds: [],
            titleDisplayName: "Travel Plus",
            descriptionDisplayName:
                "Extended travel insurance with extra coverage for your travels",
            badges: ["Popular"]
        )
        if !bannerData.contractIds.isEmpty {
            return bannerData
        }
        return nil
    }
}
