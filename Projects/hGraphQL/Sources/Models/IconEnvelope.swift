public struct IconEnvelope: Codable, Equatable, Hashable {
    public let dark: String
    public let light: String
    public init?(
        fragment: GiraffeGraphQL.IconFragment?
    ) {
        guard let fragment = fragment else { return nil }
        dark = fragment.variants.dark.pdfUrl
        light = fragment.variants.light.pdfUrl
    }
}
