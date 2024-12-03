import Foundation
import hGraphQL

public struct AddonModel: Identifiable, Equatable, Hashable, Sendable {
    public let id: String
    let title: String
    let description: String?
    let tag: String
    let informationText: String
    let activationDate: Date?
    let options: [AddonOptionModel]

    public init(
        id: String,
        title: String,
        description: String?,
        tag: String,
        informationText: String,
        activationDate: Date?,
        options: [AddonOptionModel]
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.tag = tag
        self.informationText = informationText
        self.activationDate = activationDate
        self.options = options
    }
}

public struct AddonOptionModel: Identifiable, Equatable, Hashable, Sendable {
    public let id: String
    let title: String?
    let description: String?
    let price: MonetaryAmount?
    let subOptions: [AddonSubOptionModel]
}

public struct AddonSubOptionModel: Identifiable, Equatable, Hashable, Sendable {
    public let id: String
    let title: String?
    let price: MonetaryAmount
}
