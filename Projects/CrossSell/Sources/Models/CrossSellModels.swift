import Foundation
import SwiftUI
import hCoreUI

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
    public var id: String
    public var title: String
    public var description: String
    public var webActionURL: String?
    public var imageUrl: URL?
    public var bannerText: String?
    public var buttonText: String?
    public var discountText: String?
    public var buttonDescription: String

    public init(
        id: String,
        title: String,
        description: String,
        webActionURL: String? = nil,
        bannerText: String? = nil,
        buttonText: String? = nil,
        discountText: String? = nil,
        imageUrl: URL?,
        buttonDescription: String
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
    }
}
