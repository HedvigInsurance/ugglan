import Foundation

public struct InsuranceTerm: Codable, Equatable, Hashable {
    public var displayName: String
    public var url: String

    public init(
        _ data: OctopusGraphQL.ProductVariantFragment.Document
    ) {
        self.displayName = data.displayName
        self.url = data.url
    }

    public init(
        displayName: String,
        url: String
    ) {
        self.displayName = displayName
        self.url = url
    }
}
