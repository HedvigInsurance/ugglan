import Foundation

public struct hPDFDocument: Codable, Equatable, Hashable, Identifiable, Sendable {
    public var id = UUID().uuidString
    public var displayName: String
    public var url: String
    public var type: TypeOfDocument

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
