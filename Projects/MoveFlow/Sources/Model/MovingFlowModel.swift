import Foundation
import hCore
import hGraphQL

public struct MovingFlowModel: Codable, Equatable, Hashable {
    let id: String
    let minMovingDate: String
    let maxMovingDate: String
    let numberCoInsured: Int
    let currentHomeAddresses: [MoveAddress]
    let quotes: [Quote]

    init(from data: OctopusGraphQL.MoveIntentFragment) {
        id = data.id
        minMovingDate = data.minMovingDate
        maxMovingDate = data.maxMovingDate
        numberCoInsured = data.suggestedNumberCoInsured
        currentHomeAddresses = data.currentHomeAddresses.compactMap({
            MoveAddress(from: $0.fragments.moveAddressFragment)
        })
        quotes = data.fragments.quoteFragment.quotes.compactMap({ Quote(from: $0) })
    }

    var total: MonetaryAmount {
        let amount = quotes.reduce(0, { $0 + $1.premium.floatAmount })
        return MonetaryAmount(amount: amount, currency: quotes.first?.premium.currency ?? "")
    }

    var movingDate: String {
        return quotes.first?.startDate ?? ""
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
    let address: MoveAddress
    let premium: MonetaryAmount
    let numberCoInsured: Int
    let startDate: String
    let displayName: String
    let highlights: [Highlight]
    let faqs: [FAQ]
    let insurableLimits: [InsurableLimits]
    let perils: [Perils]
    let documents: [InsuranceDocument]
    let contractType: Contract.TypeOfContract?
    let id: String
    init(from data: OctopusGraphQL.QuoteFragment.Quote) {
        id = UUID().uuidString
        address = .init(from: data.address.fragments.moveAddressFragment)
        premium = .init(fragment: data.premium.fragments.moneyFragment)
        numberCoInsured = data.numberCoInsured
        startDate = data.startDate.localDateToDate?.displayDateDotFormat ?? data.startDate
        let productVariantFragment = data.productVariant.fragments.productVariantFragment
        displayName = productVariantFragment.displayName
        highlights = productVariantFragment.highlights.compactMap({ .init($0) })
        faqs = productVariantFragment.faq.compactMap({ .init($0) })
        insurableLimits = productVariantFragment.insurableLimits.compactMap({ .init($0) })
        perils = productVariantFragment.perils.compactMap({ .init(fragment: $0) })
        documents = productVariantFragment.documents.compactMap({ .init($0) })
        contractType = Contract.TypeOfContract(rawValue: data.productVariant.typeOfContract)
    }

    var detailsInfo: [KeyValue] {
        var list: [KeyValue] = []
        list.append((L10n.changeAddressNewAddressLabel, address.street))
        list.append((L10n.changeAddressNewPostalCodeLabel, address.postalCode))
        list.append((L10n.changeAddressCoInsuredLabel, "\(numberCoInsured)"))
        return list
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
