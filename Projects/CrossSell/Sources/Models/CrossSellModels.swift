import Foundation
import SwiftUI

public struct CrossSells: Codable, Equatable, Hashable, Sendable, Identifiable {
    public let id = UUID()
    public let recommended: CrossSell?
    public let others: [CrossSell]

    enum CodingKeys: String, CodingKey {
        case id
        case recommended
        case others
    }

    public init(recommended: CrossSell?, others: [CrossSell]) {
        self.recommended = recommended
        self.others = others
    }
}

public struct CrossSell: Codable, Equatable, Hashable, Sendable, Identifiable {
    public let id: String
    let title: String
    let description: String
    let webActionURL: String?
    let imageUrl: URL?
    let bannerText: String?
    let buttonText: String?
    let discountText: String?
    let buttonDescription: String
    let leftImage: URL?
    let rightImage: URL?
    let discountPercent: Int?
    let numberOfEligibleContracts: Int

    public init(
        id: String,
        title: String,
        description: String,
        webActionURL: String? = nil,
        bannerText: String? = nil,
        buttonText: String? = nil,
        discountText: String? = nil,
        imageUrl: URL?,
        buttonDescription: String,
        discountPercent: Int? = nil,
        leftImage: URL? = nil,
        rightImage: URL? = nil,
        numberOfEligibleContracts: Int = 0
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.webActionURL = webActionURL
        self.imageUrl = imageUrl
        self.bannerText = bannerText
        self.buttonText = buttonText
        self.discountText = discountText
        self.buttonDescription = buttonDescription
        self.leftImage = leftImage
        self.rightImage = rightImage
        self.numberOfEligibleContracts = numberOfEligibleContracts
        self.discountPercent = discountPercent
    }
}
