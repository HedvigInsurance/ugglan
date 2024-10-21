public struct PDFDocument: Codable, Equatable, Hashable, Identifiable {
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
        displayName: String,
        url: String,
        type: TypeOfDocument
    ) {
        self.displayName = displayName
        self.url = url
        self.type = type
    }
}

public enum TypeOfDocument: Codable, Hashable {
    case termsAndConditions
    case preSaleInfoEuStandard
    case preSaleInfo
    case generalTerms
    case privacyPolicy
    case unknown
}

extension GraphQLEnum<OctopusGraphQL.InsuranceDocumentType> {
    var asTypeOfDocument: TypeOfDocument {
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
            }
        case .unknown:
            return .unknown
        }
    }
}
