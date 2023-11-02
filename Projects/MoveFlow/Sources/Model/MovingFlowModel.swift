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
        self.extraBuildingTypes = data.extraBuildingTypes.compactMap({ $0.rawValue })

        var faqs = [FAQ]()
        faqs.append(.init(title: L10n.changeAddressFaqDateTitle, description: L10n.changeAddressFaqDateLabel))
        faqs.append(.init(title: L10n.changeAddressFaqPriceTitle, description: L10n.changeAddressFaqPriceLabel))
        faqs.append(.init(title: L10n.changeAddressFaqRentbrfTitle, description: L10n.changeAddressFaqRentbrfLabel))
        faqs.append(.init(title: L10n.changeAddressFaqStorageTitle, description: L10n.changeAddressFaqStorageLabel))
        faqs.append(.init(title: L10n.changeAddressFaqStudentTitle, description: L10n.changeAddressFaqStudentLabel))
        self.faqs = faqs
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
        case .apartmant, .rental:
            return maxApartmentNumberCoInsured ?? 5
        case .house:
            return maxHouseNumberCoInsured ?? 5
        }
    }

}

enum MovingFlowError: Error {
    case serverError(message: String)
    case other
}

extension MovingFlowError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .serverError(message): return message
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
        startDate = data.startDate.localDateToDate?.displayDateDotFormat ?? data.startDate
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
}
