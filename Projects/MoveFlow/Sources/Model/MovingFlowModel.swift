import ChangeTier
import Contracts
import Foundation
import hCore
import hCoreUI
import hGraphQL

public struct MovingFlowModel: Codable, Equatable, Hashable {
    let id: String
    let isApartmentAvailableforStudent: Bool
    let maxApartmentNumberCoInsured: Int?
    let maxApartmentSquareMeters: Int?
    let maxHouseNumberCoInsured: Int?
    let maxHouseSquareMeters: Int?
    let minMovingDate: String
    let maxMovingDate: String
    let suggestedNumberCoInsured: Int
    let currentHomeAddresses: [MoveAddress]
    let quotes: [Quote]
    let faqs: [FAQ]
    let extraBuildingTypes: [ExtraBuildingType]
    let homeQuotes: [Quote]
    let changeTier: ChangeTierIntentModel?
    init(from data: OctopusGraphQL.MoveIntentFragment) {
        id = data.id
        let minMovingDate = data.minMovingDate
        let maxMovingDate = data.maxMovingDate
        let minMovingDateDate = minMovingDate.localDateToDate
        let maxMovingDateDate = maxMovingDate.localDateToDate
        if let minMovingDateDate, let maxMovingDateDate {
            if minMovingDateDate < maxMovingDateDate {
                self.minMovingDate = minMovingDate
                self.maxMovingDate = maxMovingDate
            } else {
                self.maxMovingDate = minMovingDate
                self.minMovingDate = maxMovingDate
            }
        } else {
            self.minMovingDate = data.minMovingDate
            self.maxMovingDate = data.maxMovingDate
        }
        isApartmentAvailableforStudent = data.isApartmentAvailableforStudent ?? false
        maxApartmentNumberCoInsured = data.maxApartmentNumberCoInsured
        maxApartmentSquareMeters = data.maxApartmentSquareMeters
        maxHouseNumberCoInsured = data.maxHouseNumberCoInsured
        maxHouseSquareMeters = data.maxHouseSquareMeters

        suggestedNumberCoInsured = data.suggestedNumberCoInsured
        currentHomeAddresses = data.currentHomeAddresses.compactMap({
            MoveAddress(from: $0.fragments.moveAddressFragment)
        })
        quotes = data.fragments.quoteFragment.quotes.compactMap({ Quote(from: $0) })
        homeQuotes = data.fragments.quoteFragment.mtaQuotes?.compactMap({ Quote(from: $0) }) ?? []
        changeTier = {
            if let data = data.fragments.quoteFragment.homeQuotes, !data.isEmpty {
                return ChangeTierIntentModel.initWith(data: data)
            }
            return nil
        }()

        self.extraBuildingTypes = data.extraBuildingTypes.compactMap({ $0.rawValue })

        var faqs = [FAQ]()
        faqs.append(.init(title: L10n.changeAddressFaqDateTitle, description: L10n.changeAddressFaqDateLabel))
        faqs.append(.init(title: L10n.changeAddressFaqPriceTitle, description: L10n.changeAddressFaqPriceLabel))
        faqs.append(.init(title: L10n.changeAddressFaqRentbrfTitle, description: L10n.changeAddressFaqRentbrfLabel))
        faqs.append(.init(title: L10n.changeAddressFaqStorageTitle, description: L10n.changeAddressFaqStorageLabel))
        faqs.append(.init(title: L10n.changeAddressFaqStudentTitle, description: L10n.changeAddressFaqStudentLabel))
        self.faqs = faqs
    }

    init(
        id: String,
        isApartmentAvailableforStudent: Bool,
        maxApartmentNumberCoInsured: Int?,
        maxApartmentSquareMeters: Int?,
        maxHouseNumberCoInsured: Int?,
        maxHouseSquareMeters: Int?,
        minMovingDate: String,
        maxMovingDate: String,
        suggestedNumberCoInsured: Int,
        currentHomeAddresses: [MoveAddress],
        quotes: [Quote],
        faqs: [FAQ],
        extraBuildingTypes: [ExtraBuildingType]
    ) {
        self.id = id
        self.isApartmentAvailableforStudent = isApartmentAvailableforStudent
        self.maxApartmentNumberCoInsured = maxApartmentNumberCoInsured
        self.maxApartmentSquareMeters = maxApartmentSquareMeters
        self.maxHouseNumberCoInsured = maxHouseNumberCoInsured
        self.maxHouseSquareMeters = maxHouseSquareMeters
        self.minMovingDate = minMovingDate
        self.maxMovingDate = maxMovingDate
        self.suggestedNumberCoInsured = suggestedNumberCoInsured
        self.currentHomeAddresses = currentHomeAddresses
        self.quotes = quotes
        self.faqs = faqs
        self.extraBuildingTypes = extraBuildingTypes
        self.homeQuotes = []
        self.changeTier = nil
    }

    var total: MonetaryAmount {
        let amount = quotes.reduce(0, { $0 + $1.premium.floatAmount })
        return MonetaryAmount(amount: amount, currency: quotes.first?.premium.currency ?? "")
    }

    var movingDate: String {
        return quotes.first?.startDate ?? ""
    }

    func maxNumberOfCoinsuredFor(_ type: HousingType) -> Int {
        switch type {
        case .apartment, .rental:
            return maxApartmentNumberCoInsured ?? 5
        case .house:
            return maxHouseNumberCoInsured ?? 5
        }
    }

}

enum MovingFlowError: Error {
    case serverError(message: String)
    case missingDataError(message: String)
    case other
}

extension MovingFlowError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .serverError(message): return message
        case let .missingDataError(message): return message
        case .other: return L10n.General.errorBody
        }
    }
}

struct MoveAddress: Codable, Equatable, Hashable {
    let id: String
    let street: String
    let postalCode: String
    let city: String?

    init(from data: OctopusGraphQL.MoveAddressFragment) {
        id = data.id
        street = data.street
        postalCode = data.postalCode
        city = data.city
    }
}

struct Quote: Codable, Equatable, Hashable {
    typealias KeyValue = (key: String, value: String)
    let premium: MonetaryAmount
    let startDate: String
    let displayName: String
    let insurableLimits: [InsurableLimits]
    let perils: [Perils]
    let documents: [InsuranceDocument]
    let contractType: Contract.TypeOfContract?
    let id: String
    let displayItems: [DisplayItem]
    let exposureName: String?

    init(from data: OctopusGraphQL.QuoteFragment.Quote) {
        id = UUID().uuidString
        premium = .init(fragment: data.premium.fragments.moneyFragment)
        startDate = data.startDate.localDateToDate?.displayDateDDMMMYYYYFormat ?? data.startDate
        let productVariantFragment = data.productVariant.fragments.productVariantFragment
        displayName = productVariantFragment.displayName
        exposureName = data.exposureName
        insurableLimits = productVariantFragment.insurableLimits.compactMap({
            .init(label: $0.label, limit: $0.limit, description: $0.description)
        })
        perils = productVariantFragment.perils.compactMap({ .init(fragment: $0) })
        documents = productVariantFragment.documents.compactMap({ .init($0) })
        contractType = Contract.TypeOfContract(rawValue: data.productVariant.typeOfContract)
        displayItems = data.displayItems.map({ .init($0) })
    }

    init(from data: OctopusGraphQL.QuoteFragment.MtaQuote) {
        id = UUID().uuidString
        premium = .init(fragment: data.premium.fragments.moneyFragment)
        startDate = data.startDate.localDateToDate?.displayDateDDMMMYYYYFormat ?? data.startDate
        let productVariantFragment = data.productVariant.fragments.productVariantFragment
        displayName = productVariantFragment.displayName
        exposureName = data.exposureName
        insurableLimits = productVariantFragment.insurableLimits.compactMap({
            .init(label: $0.label, limit: $0.limit, description: $0.description)
        })
        perils = productVariantFragment.perils.compactMap({ .init(fragment: $0) })
        documents = productVariantFragment.documents.compactMap({ .init($0) })
        contractType = Contract.TypeOfContract(rawValue: data.productVariant.typeOfContract)
        displayItems = data.displayItems.map({ .init($0) })
    }

}

struct InsuranceDocument: Codable, Equatable, Hashable {
    let displayName: String
    let url: String

    init(_ data: OctopusGraphQL.ProductVariantFragment.Document) {
        self.displayName = data.displayName
        self.url = data.url
    }
}

struct DisplayItem: Codable, Equatable, Hashable {
    let displaySubtitle: String?
    let displayTitle: String
    let displayValue: String

    init(_ data: OctopusGraphQL.QuoteFragment.Quote.DisplayItem) {
        displaySubtitle = data.displaySubtitle
        displayTitle = data.displayTitle
        displayValue = data.displayValue
    }

    init(_ data: OctopusGraphQL.QuoteFragment.MtaQuote.DisplayItem) {
        displaySubtitle = data.displaySubtitle
        displayTitle = data.displayTitle
        displayValue = data.displayValue
    }
}

extension ChangeTierIntentModel {
    static func initWith(data: [OctopusGraphQL.QuoteFragment.HomeQuote]) -> ChangeTierIntentModel {

        var currentTier: Tier?
        var currentDeductible: Deductible?

        func getFilteredTiers(
            quotes: [OctopusGraphQL.QuoteFragment.HomeQuote]
        ) -> [Tier] {
            // list of all unique tierNames
            var allTiers: [Tier] = []

            var uniqueTierNames: [String] = []
            quotes
                .forEach({ tier in
                    let tierNameIsNotInList = uniqueTierNames.first(where: { $0 == (tier.tierName) })?.isEmpty
                    if tierNameIsNotInList ?? true {
                        uniqueTierNames.append(tier.tierName)
                    }
                })

            /* filter tiers and deductibles*/
            uniqueTierNames.forEach({ tierName in
                let allQuotesWithNameX = quotes.filter({ $0.tierName == tierName })
                var allDeductiblesForX: [Deductible] = []

                allQuotesWithNameX
                    .forEach({ quote in
                        if let deductableAmount = quote.deductible?.amount {
                            let deductible = Deductible(
                                deductibleAmount: .init(fragment: deductableAmount.fragments.moneyFragment),
                                deductiblePercentage: (quote.deductible?.percentage == 0)
                                    ? nil : quote.deductible?.percentage,
                                subTitle: quote.deductible?.displayText,
                                premium: .init(
                                    optionalFragment: allQuotesWithNameX.first?.premium.fragments.moneyFragment
                                )
                            )
                            allDeductiblesForX.append(deductible)
                        }
                    })

                var displayItems: [Tier.TierDisplayItem] = []
                allQuotesWithNameX
                    .forEach({
                        displayItems.append(
                            contentsOf: $0.displayItems.map({
                                Tier.TierDisplayItem(
                                    title: $0.displayTitle,
                                    subTitle: $0.displaySubtitle,
                                    value: $0.displayValue
                                )
                            })
                        )
                    })

                let FAQs: [FAQ] = [
                    .init(title: "question 1", description: "..."),
                    .init(title: "question 2", description: "..."),
                    .init(title: "question 3", description: "..."),
                ]

                allTiers.append(
                    .init(
                        id: allQuotesWithNameX.first?.id ?? "",
                        name: allQuotesWithNameX.first?.tierName ?? "",
                        level: allQuotesWithNameX.first?.tierLevel ?? 0,
                        deductibles: allDeductiblesForX,
                        premium: .init(optionalFragment: allQuotesWithNameX.first?.premium.fragments.moneyFragment)
                            ?? .init(amount: "0", currency: "SEK"),
                        displayItems: displayItems,
                        exposureName: "TODO",
                        productVariant: .init(
                            data: allQuotesWithNameX.first?.productVariant.fragments.productVariantFragment
                        ),
                        FAQs: FAQs
                    )
                )
            })
            return allTiers
        }

        let tiers = getFilteredTiers(quotes: data)
        let first = data.first
        let intentModel: ChangeTierIntentModel = .init(
            activationDate: first?.startDate.localDateToDate ?? Date(),
            tiers: tiers,
            currentPremium: .init(
                amount: "0",  //String(currentContract.currentAgreement.premium.amount),
                currency: "SEK$$"  //currentContract.currentAgreement.premium.currencyCode.rawValue
            ),
            currentTier: currentTier,
            currentDeductible: currentDeductible,
            canEditTier: true
        )
        return intentModel
    }

}
