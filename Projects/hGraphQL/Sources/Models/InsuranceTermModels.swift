import Foundation

public struct InsuranceTerm: Codable, Equatable, Hashable {
    public var displayName: String
    public var url: String
    public var type: InsuranceDocumentType
    
    public init(
        _ data: OctopusGraphQL.ProductVariantFragment.Document
    ) {
        self.displayName = data.displayName
        self.url = data.url
        self.type = InsuranceDocumentType.resolve(for: data.type)
    }
}

public enum InsuranceDocumentType: String, Codable {
    case termsAndConditions = "TERMS_AND_CONDITIONS"
    case preSaleInfoEUStandard = "PRE_SALE_INFO_EU_STANDARD"
    case preSaleInfo = "PRE_SALE_INFO"
    case generalTerms = "GENERAL_TERMS"
    case privacyPolicy = "PRIVACY_POLICY"
    case unknown = "UNKNOWN"
    
    static func resolve(for insuranceDocumentType: OctopusGraphQL.InsuranceDocumentType) -> Self {
        if let concreteTypeOfContract = Self(rawValue: insuranceDocumentType.rawValue) {
            return concreteTypeOfContract
        }
        
        log.warn(
            "Got an unknown type of document \(insuranceDocumentType.rawValue) that couldn't be resolved.",
            error: nil,
            attributes: nil
        )
        return .unknown
    }
}
