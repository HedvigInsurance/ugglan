import Foundation
import hGraphQL

public struct AddonModel: Identifiable, Equatable, Hashable {
    public let id: String
    let title: String
    let tag: String
    let subTitle: String?
    let informationText: String
    let options: [AddonOptionModel]

    public init(
        id: String,
        title: String,
        tag: String,
        subTitle: String?,
        informationText: String,
        options: [AddonOptionModel]
    ) {
        self.id = id
        self.title = title
        self.tag = tag
        self.subTitle = subTitle
        self.informationText = informationText
        self.options = options
    }
}

public struct AddonOptionModel: Identifiable, Equatable, Hashable {
    public let id: String
    let title: String?
    let subtitle: String?
    let price: MonetaryAmount?
    let subOptions: [AddonSubOptionModel]
    let isAlreadyIncluded: Bool
}

public struct AddonSubOptionModel: Identifiable, Equatable, Hashable {
    public let id: String
    let title: String?
    let subtitle: String?
    let price: MonetaryAmount
}
