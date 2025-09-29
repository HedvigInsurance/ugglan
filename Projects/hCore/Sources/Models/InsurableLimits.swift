import Foundation
import hGraphQL

public struct InsurableLimits: Codable, Hashable, Identifiable, Sendable {
    public var id = UUID().uuidString
    public let label: String
    public let limit: String?
    public let description: String

    public init(
        label: String,
        limit: String? = nil,
        description: String
    ) {
        self.label = label
        self.limit = limit
        self.description = description
    }

    public init(
        _ data: OctopusGraphQL.ProductVariantFragment.InsurableLimit
    ) {
        label = data.label
        limit = data.limit
        description = data.description
    }
}
