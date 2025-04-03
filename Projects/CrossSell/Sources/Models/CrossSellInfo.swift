import Foundation
import hCore
import hGraphQL

public struct CrossSellInfo: Identifiable, Equatable, Sendable {
    public static func == (lhs: CrossSellInfo, rhs: CrossSellInfo) -> Bool {
        lhs.id == rhs.id
    }

    public let id: String = UUID().uuidString
    public let type: CrossSellInfoType
    let additionalInfo: (any Encodable & Sendable)?

    public init<T>(type: CrossSellInfoType, additionalInfo: T) where T: Encodable & Codable & Sendable {
        self.type = type
        self.additionalInfo = additionalInfo
    }

    public init(type: CrossSellInfoType) {
        self.type = type
        self.additionalInfo = nil
    }

    public enum CrossSellInfoType: String, Codable, Equatable, Sendable {
        case home
        case claim
        case changeTier
        case addon
        case coInsured
        case moveFlow
    }

    fileprivate func asLogData() -> [AttributeKey: AttributeValue] {
        var data = [AttributeKey: AttributeValue]()
        data["source"] = type.rawValue
        data["info"] = additionalInfo
        return data
    }

    @MainActor
    func logCrossSellEvent() {
        log.addUserAction(
            type: .custom,
            name: "crossSell",
            error: nil,
            attributes: self.asLogData()
        )
    }
}
