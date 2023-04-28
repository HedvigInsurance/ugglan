import Foundation

public struct FAQ: Codable, Equatable, Hashable {
    public var title: String
    public var description: String?

    init?(
        _ data: OctopusGraphQL.ProductVariantFragment.Faq
    ) {
        guard let description = data.body else { return nil }
        self.title = data.headline
        self.description = description
    }
}
