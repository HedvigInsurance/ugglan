public struct Perils: Codable, Equatable, Hashable {
    public let title: String
    public let description: String
    public let icon: IconEnvelope?
    public let color: String?
    public let covered: [String]
    public let exceptions: [String]
    public let info: String

    public init(
        fragment: OctopusGraphQL.ProductVariantFragment.Peril
    ) {
        title = fragment.title
        description = fragment.description
        icon = nil
        info = fragment.info
        covered = fragment.covered
        exceptions = fragment.exceptions
        color = fragment.colorCode
    }

    public init(
        fragment: GiraffeGraphQL.PerilFragment
    ) {
        title = fragment.title
        description = fragment.description
        icon = nil
        covered = fragment.covered
        exceptions = fragment.exceptions
        color = ""
        info = ""
    }
}
