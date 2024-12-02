import Foundation
import hGraphQL

@MainActor
public struct AddonModel: Identifiable, Equatable, Hashable {
    public let id: String
    let title: String
    let subTitle: String?
    let tag: String
    let informationText: String
    let options: [AddonOptionModel]

    public init(
        id: String,
        title: String,
        subTitle: String?,
        tag: String,
        informationText: String,
        options: [AddonOptionModel]
    ) {
        self.id = id
        self.title = title
        self.subTitle = subTitle
        self.tag = tag
        self.informationText = informationText
        self.options = options
    }
}

@MainActor
public struct AddonOptionModel: Identifiable, Equatable, Hashable {
    public let id: String
    let title: String?
    let subtitle: String?
    let price: MonetaryAmount?
    let subOptions: [AddonSubOptionModel]
}

@MainActor
public struct AddonSubOptionModel: Identifiable, Equatable, Hashable {
    public let id: String
    let title: String?
    let subtitle: String?
    let price: MonetaryAmount
}
