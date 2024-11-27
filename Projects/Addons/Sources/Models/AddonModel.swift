import Foundation
import hGraphQL

public struct AddonModel: Identifiable, Equatable, Hashable {
    public let id: String
    let title: String
    let subTitle: String?
    let informationText: String
    let options: [AddonOptionModel]?
}

public struct AddonOptionModel: Identifiable, Equatable, Hashable {
    public let id: String
    let title: String?
    let subtitle: String?
    let price: MonetaryAmount?
    let subOptions: [AddonSubOptionModel]
    let isAlreadyIncluded: Bool

    var getPillDisplayText: String {
        isAlreadyIncluded ? "Ingår" : price?.formattedAmountPerMonth ?? ""
    }
}

public struct AddonSubOptionModel: Identifiable, Equatable, Hashable {
    public let id: String
    let title: String?
    let subtitle: String?
    let price: MonetaryAmount
}
