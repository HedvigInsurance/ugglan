import Foundation
import hGraphQL

public struct AddonModel: Identifiable, Equatable, Hashable {
    public var id = UUID()
    let title: String
    let subTitle: String?
    let options: [AddonOptionModel]?
}

public struct AddonOptionModel: Identifiable, Equatable, Hashable {
    public var id = UUID()
    let title: String?
    let subtitle: String?
    let price: MonetaryAmount?
    let subOptions: [AddonSubOptionModel]
}

public struct AddonSubOptionModel: Identifiable, Equatable, Hashable {
    public var id = UUID()
    let title: String?
    let subtitle: String?
    let price: MonetaryAmount
}
