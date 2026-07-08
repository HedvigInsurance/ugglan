import Foundation
import SwiftUI

public struct CrossSells: Codable, Equatable, Hashable, Sendable, Identifiable {
    public let id = UUID()
    public let recommended: RecommendedCrossSell?
    public let others: [CrossSell]
    public let discountAvailable: Bool
    enum CodingKeys: String, CodingKey {
        case id
        case recommended
        case others
        case discountAvailable
    }

    var hasRecommendation: Bool {
        recommended != nil
    }

    public init(recommended: RecommendedCrossSell?, others: [CrossSell], discountAvailable: Bool) {
        self.recommended = recommended
        self.others = others
        self.discountAvailable = discountAvailable
    }
}

public enum RecommendedCrossSell: Codable, Equatable, Hashable, Sendable, Identifiable {
    case insurance(CrossSell)
    case addon(AddonCrossSell)

    public var id: String {
        switch self {
        case let .insurance(insurance): return insurance.id
        case let .addon(addon): return addon.id
        }
    }

    /// Optional banner text. Both insurance and addon recommendations may omit it,
    /// in which case callers fall back to a default.
    public var bannerText: String? {
        switch self {
        case let .insurance(insurance): return insurance.bannerText
        case let .addon(addon): return addon.banner
        }
    }
}

public struct AddonCrossSell: Codable, Equatable, Hashable, Sendable {
    let id: String
    let title: String
    let description: String
    let buttonText: String
    let deepLink: String
    /// Optional banner text shown above the card; callers fall back to a default when nil.
    let banner: String?
    /// Benefit rows shown as a checkmark list; empty when there are none.
    let benefits: [String]
    let imageUrl: URL?

    public init(
        id: String,
        title: String,
        description: String,
        buttonText: String,
        deepLink: String,
        banner: String? = nil,
        benefits: [String] = [],
        imageUrl: URL?
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.buttonText = buttonText
        self.deepLink = deepLink
        self.banner = banner
        self.benefits = benefits
        self.imageUrl = imageUrl
    }
}

public struct CrossSell: Codable, Equatable, Hashable, Sendable, Identifiable {
    public let id: String
    let title: String
    let description: String
    let buttonTitle: String
    let webActionURL: String?
    public let imageUrl: URL?
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
        buttonTitle: String,
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
        self.buttonTitle = buttonTitle
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
