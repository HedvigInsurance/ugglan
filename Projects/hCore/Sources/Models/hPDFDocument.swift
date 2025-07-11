import hGraphQL

public struct hPDFDocument: Codable, Equatable, Hashable, Identifiable, Sendable {
    public var id: String?
    public var displayName: String
    public var url: String
    public var type: TypeOfDocument

    public init(
        _ data: OctopusGraphQL.ProductVariantFragment.Document
    ) {
        self.displayName = data.displayName
        self.url = data.url
        self.type = data.type.asTypeOfDocument
    }

    public init(
        _ data: OctopusGraphQL.AddonVariantFragment.Document
    ) {
        self.displayName = data.displayName
        self.url = data.url
        self.type = data.type.asTypeOfDocument
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

public enum TypeOfDocument: Codable, Hashable, Sendable {
    case termsAndConditions
    case preSaleInfoEuStandard
    case preSaleInfo
    case generalTerms
    case privacyPolicy
    case appealInstruction
    case unknown
}

extension GraphQLEnum<OctopusGraphQL.InsuranceDocumentType> {
    public var asTypeOfDocument: TypeOfDocument {
        switch self {
        case .case(let type):
            switch type {
            case .generalTerms:
                return .generalTerms
            case .preSaleInfo:
                return .preSaleInfo
            case .preSaleInfoEuStandard:
                return .preSaleInfoEuStandard
            case .privacyPolicy:
                return .privacyPolicy
            case .termsAndConditions:
                return .termsAndConditions
            case .scarTable:
                return .unknown
            }
        case .unknown:
            return .unknown
        }
    }
}
