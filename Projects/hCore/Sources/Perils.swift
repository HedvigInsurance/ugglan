import hGraphQL

public struct Perils: Codable, Equatable, Hashable {
    public let id: String?
    public let title: String
    public let description: String
    public let shortDescription: String?
    public let info: String?
    public let color: String?
    public let covered: [String]
    public let exceptions: [String]

    public init(
        fragment: OctopusGraphQL.ProductVariantFragment.Peril
    ) {
        id = fragment.id
        title = fragment.title
        description = fragment.description
        covered = fragment.covered
        exceptions = fragment.exceptions
        color = fragment.colorCode
        shortDescription = fragment.shortDescription
        info = fragment.info
    }
}
