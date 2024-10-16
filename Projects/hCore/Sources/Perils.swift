import hGraphQL

public struct Perils: Codable, Equatable, Hashable {
    public let id: String?
    public let title: String
    public let description: String
    public let color: String?
    public let covered: [String]
    public let isDisabled: Bool

    public init(
        id: String?,
        title: String,
        description: String,
        color: String?,
        covered: [String],
        isDisabled: Bool? = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.color = color
        self.covered = covered
        self.isDisabled = isDisabled ?? false
    }

    public init(
        fragment: OctopusGraphQL.ProductVariantFragment.Peril
    ) {
        id = fragment.id
        title = fragment.title
        description = fragment.description
        covered = fragment.covered
        color = fragment.colorCode
        isDisabled = false
    }

    public func asDisabled() -> Perils {
        return .init(
            id: id,
            title: title,
            description: description,
            color: color,
            covered: covered,
            isDisabled: true
        )
    }
}
