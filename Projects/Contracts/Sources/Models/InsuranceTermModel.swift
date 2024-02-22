import Foundation
import hGraphQL

public struct InsuranceTerm: Codable, Equatable, Hashable {
    public var displayName: String
    public var url: String
    public var type: TypeOfDocument

    public init(
        _ data: OctopusGraphQL.ProductVariantFragment.Document
    ) {
        self.displayName = data.displayName
        self.url = data.url
        self.type = TypeOfDocument.resolve(for: data.type.rawValue)
    }

    public init(
        displayName: String,
        url: String,
        type: TypeOfDocument
    ) {
        self.displayName = displayName
        self.url = url
        self.type = type
    }
}

public enum TypeOfDocument: String, Codable {
    case termsAndConditions = "TERMS_AND_CONDITIONS"
    case preSaleInfoEuStandard = "PRE_SALE_INFO_EU_STANDARD"
    case preSaleInfo = "PRE_SALE_INFO"
    case generalTerms = "GENERAL_TERMS"
    case privacyPolicy = "PRIVACY_POLICY"
    case unknown = "UNKNOWN"

    static func resolve(for typeOfDocument: String) -> Self {
        if let concreteTypeOfDocument = Self(rawValue: typeOfDocument) {
            return concreteTypeOfDocument
        }

        log.warn(
            "Got an unknown type of document \(typeOfDocument) that couldn't be resolved.",
            error: nil,
            attributes: nil
        )
        return .unknown
    }
}
