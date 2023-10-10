import Foundation
import hGraphQL

public struct Highlight: Codable, Equatable, Hashable {
    public var title: String
    public var description: String

    public init(_ data: OctopusGraphQL.ProductVariantFragment.Highlight) {
        self.title = data.title
        self.description = data.description
    }
}
