import hGraphQL

public struct ProductVariant: Codable, Hashable, Sendable {
    public let termsVersion: String
    public let typeOfContract: String
    public let perils: [Perils]
    public let insurableLimits: [InsurableLimits]
    public let documents: [hPDFDocument]
    public let displayName: String
    public let displayNameTier: String?
    public let tierDescription: String?

    public init(
        termsVersion: String,
        typeOfContract: String,
        perils: [Perils],
        insurableLimits: [InsurableLimits],
        documents: [hPDFDocument],
        displayName: String,
        displayNameTier: String?,
        tierDescription: String?
    ) {
        self.termsVersion = termsVersion
        self.typeOfContract = typeOfContract
        self.perils = perils
        self.insurableLimits = insurableLimits
        self.documents = documents
        self.displayName = displayName
        self.displayNameTier = displayNameTier
        self.tierDescription = tierDescription
    }

    public init(
        data: OctopusGraphQL.ProductVariantFragment
    ) {
        displayName = data.displayName
        termsVersion = data.termsVersion
        typeOfContract = data.typeOfContract
        perils = data.perils.map { .init(fragment: $0.fragments.perilFragment) }
        insurableLimits = data.insurableLimits.map { .init($0) }
        documents = data.documents.map { .init($0) }
        displayNameTier = data.displayNameTier
        tierDescription = data.tierDescription
    }

    public init?(
        data: OctopusGraphQL.ProductVariantFragment?
    ) {
        guard let data else { return nil }
        self.init(data: data)
    }
}
