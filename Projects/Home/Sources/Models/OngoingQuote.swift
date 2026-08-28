import Foundation
import hCore

public struct OngoingQuote: Codable, Equatable, Hashable, Identifiable, Sendable {
    public let id: String
    let title: String
    let subtitle: String?
    let monthlyNet: MonetaryAmount?
    let resumeUrl: URL
    let pillowImageUrl: URL?

    public init(
        id: String,
        title: String,
        subtitle: String?,
        monthlyNet: MonetaryAmount?,
        resumeUrl: URL,
        pillowImageUrl: URL?
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.monthlyNet = monthlyNet
        self.resumeUrl = resumeUrl
        self.pillowImageUrl = pillowImageUrl
    }

    /// The price when the quote has one, otherwise what the member is buying for.
    var secondaryText: String? {
        monthlyNet?.formattedAmountPerMonth ?? subtitle
    }
}
