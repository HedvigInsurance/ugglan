import hGraphQL

public struct Perils: Codable, Equatable, Hashable {
    public let title: String
    public let description: String
    public let icon: IconEnvelope?
    public let color: String?
    public let covered: [String]
    public let exceptions: [String]

    public init(
        fragment: GiraffeGraphQL.PerilFragment
    ) {
        title = fragment.title
        description = fragment.description
        icon = .init(fragment: fragment.icon.fragments.iconFragment)
        covered = fragment.covered
        exceptions = fragment.exceptions
        color = nil
    }

    public init(
        fragment: OctopusGraphQL.ProductVariantFragment.Peril
    ) {
        title = fragment.title
        description = fragment.description
        icon = nil
        covered = fragment.covered
        exceptions = fragment.exceptions
        color = fragment.colorCode
    }
}
