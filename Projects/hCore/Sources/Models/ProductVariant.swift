import hGraphQL

public struct ProductVariant: Codable, Hashable {
    public let termsVersion: String
    let typeOfContract: String
    let partner: String?
    public let perils: [Perils]
    public let insurableLimits: [InsurableLimits]
    public let documents: [hPDFDocument]
    public let displayName: String
    public let displayNameTier: String?
    public let tierDescription: String?

    public init(
        termsVersion: String,
        typeOfContract: String,
        partner: String?,
        perils: [Perils],
        insurableLimits: [InsurableLimits],
        documents: [hPDFDocument],
        displayName: String,
        displayNameTier: String?,
        tierDescription: String?
    ) {
        self.termsVersion = termsVersion
        self.typeOfContract = typeOfContract
        self.partner = partner
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
        self.displayName = data.displayName
        self.termsVersion = data.termsVersion
        self.typeOfContract = data.typeOfContract
        self.partner = data.partner ?? ""
        self.perils = data.perils.map({ .init(fragment: $0) })
        self.insurableLimits = data.insurableLimits.map({ .init($0) })
        self.documents = data.documents.map({ .init($0) })
        self.displayNameTier = data.displayNameTier
        self.tierDescription = data.tierDescription
    }

    public init?(
        data: OctopusGraphQL.ProductVariantFragment?
    ) {
        guard let data else { return nil }
        self.init(data: data)
    }
}
