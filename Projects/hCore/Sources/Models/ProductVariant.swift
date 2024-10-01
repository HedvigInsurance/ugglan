import hGraphQL

public struct ProductVariant: Codable, Hashable {
    let termsVersion: String
    let typeOfContract: String
    let partner: String?
    public let perils: [Perils]
    public let insurableLimits: [InsurableLimits]
    public let documents: [InsuranceTerm]
    public let displayName: String
    public let displayNameTier: String?
    public let displayNameTierLong: String?

    public init(
        termsVersion: String,
        typeOfContract: String,
        partner: String?,
        perils: [Perils],
        insurableLimits: [InsurableLimits],
        documents: [InsuranceTerm],
        displayName: String,
        displayNameTier: String?,
        displayNameTierLong: String?
    ) {
        self.termsVersion = termsVersion
        self.typeOfContract = typeOfContract
        self.partner = partner
        self.perils = perils
        self.insurableLimits = insurableLimits
        self.documents = documents
        self.displayName = displayName
        self.displayNameTier = displayNameTier
        self.displayNameTierLong = displayNameTierLong
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
        self.displayNameTierLong = data.displayNameTierLong
    }

    public init?(
        data: OctopusGraphQL.ProductVariantFragment?
    ) {
        guard let data else { return nil }
        self.init(data: data)
    }
}
