import hGraphQL

public struct AddonVariant: Codable, Equatable, Hashable, Sendable {
    public let displayName: String
    public let documents: [hPDFDocument]
    public let perils: [Perils]
    public let product: String
    public let termsVersion: String

    public init(
        displayName: String,
        documents: [hPDFDocument],
        perils: [Perils],
        product: String,
        termsVersion: String
    ) {
        self.displayName = displayName
        self.documents = documents
        self.perils = perils
        self.product = product
        self.termsVersion = termsVersion
    }
}

public extension AddonVariant {
    init(
        fragment: OctopusGraphQL.AddonVariantFragment?
    ) {
        self.init(
            displayName: fragment?.displayName ?? "",
            documents: fragment?.documents.map { .init($0) } ?? [],
            perils: fragment?.addonPerils.map { .init(fragment: $0) } ?? [],
            product: fragment?.product ?? "",
            termsVersion: fragment?.termsVersion ?? ""
        )
    }
}
