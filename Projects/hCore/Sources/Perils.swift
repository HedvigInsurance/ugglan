import hGraphQL

public struct Perils: Codable, Equatable, Hashable {
    public let id: String?
    public let title: String
    public let description: String
    public let info: String?
    public let color: String?
    public let covered: [String]

    public init(
        id: String?,
        title: String,
        description: String,
        info: String?,
        color: String?,
        covered: [String]
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.info = info
        self.color = color
        self.covered = covered
    }

    public init(
        fragment: OctopusGraphQL.ProductVariantFragment.Peril
    ) {
        id = fragment.id
        title = fragment.title
        description = fragment.description
        covered = fragment.covered
        color = fragment.colorCode
        info = fragment.info
    }
}
