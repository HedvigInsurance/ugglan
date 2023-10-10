import Foundation
import hGraphQL

public struct FAQ: Codable, Equatable, Hashable {
    public var title: String
    public var description: String?

    public init(title: String, description: String?) {
        self.title = title
        self.description = description
    }

    public init?(
        _ data: OctopusGraphQL.ProductVariantFragment.Faq
    ) {
        guard let description = data.body else { return nil }
        self.title = data.headline
        self.description = description
    }
}
