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
    let address: MoveAddress
    let premium: MonetaryAmount
    let numberCoInsured: Int
    let startDate: String

    init(from data: OctopusGraphQL.QuoteFragment.Quote) {
        address = .init(from: data.address.fragments.moveAddressFragment)
        premium = .init(fragment: data.premium.fragments.moneyFragment)
        numberCoInsured = data.numberCoInsured
        startDate = data.startDate
    }
}
