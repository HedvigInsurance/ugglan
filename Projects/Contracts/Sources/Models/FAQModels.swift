import Foundation
import hGraphQL

public struct FAQ: Codable, Equatable, Hashable {
    public var title: String
    public var description: String?

    public init(
        _ data: OctopusGraphQL.ProductVariantFragment.Faq
    ) {
        self.title = data.headline
        self.description = data.body ?? ""
    }
}
