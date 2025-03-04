import hGraphQL

public struct Perils: Codable, Equatable, Hashable, Sendable {
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
        fragment: OctopusGraphQL.AddonVariantFragment.AddonPeril
    ) {
        var description = fragment.description ?? ""
        let coverageTexts = [fragment.coverageText].compactMap({ $0 })
        if !coverageTexts.isEmpty {
            description += "\r\n"
        }
        [fragment.coverageText].compactMap({ $0 })
            .forEach { coverageText in
                description += "\r\n \(coverageText)"
            }
        self.id = fragment.title
        self.title = fragment.title
        self.description = description
        self.covered = []
        self.color = fragment.colorCode
        self.isDisabled = false
    }

    public init(
        fragment: OctopusGraphQL.PerilFragment
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
