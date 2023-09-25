import Foundation

public struct InsuranceTerm: Codable, Equatable, Hashable {
    public var displayName: String
    public var url: URL

    init?(
        _ data: OctopusGraphQL.ProductVariantFragment.Document
    ) {
        guard let url = URL(string: data.url) else {

            return nil
        }

        self.displayName = data.displayName
        self.url = url
    }
}
