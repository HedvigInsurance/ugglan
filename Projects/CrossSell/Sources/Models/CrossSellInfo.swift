import Foundation
import Logger
import hCore

public struct CrossSellInfo: Identifiable, Equatable, Sendable {
    public static func == (lhs: CrossSellInfo, rhs: CrossSellInfo) -> Bool {
        lhs.id == rhs.id
    }

    public let id: String = UUID().uuidString
    public let type: CrossSellSource
    /// Contract that was changed in the flow. When set, enables addon recommendations for that contract.
    public let contractId: String?
    let additionalInfo: (any Encodable & Sendable)?

    public init<T>(type: CrossSellSource, contractId: String? = nil, additionalInfo: T)
    where T: Encodable & Codable & Sendable {
        self.type = type
        self.contractId = contractId
        self.additionalInfo = additionalInfo
    }

    public init(type: CrossSellSource, contractId: String? = nil) {
        self.type = type
        self.contractId = contractId
        additionalInfo = nil
    }

    fileprivate func asLogData() -> [AttributeKey: AttributeValue] {
        var data = [AttributeKey: AttributeValue]()
        data["source"] = type.rawValue
        data["info"] = additionalInfo
        return data
    }

    @MainActor
    public func logCrossSellEvent() {
        log.addUserAction(
            type: .custom,
            name: "crossSell",
            error: nil,
            attributes: asLogData()
        )
    }

    public func getCrossSell() async throws -> CrossSells {
        try await CrossSellService().getCrossSell(source: type, contractId: contractId)
    }
}
