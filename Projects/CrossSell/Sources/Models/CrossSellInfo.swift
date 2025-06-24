import Foundation
import Logger
import hCore

public struct CrossSellInfo: Identifiable, Equatable, Sendable {
    public static func == (lhs: CrossSellInfo, rhs: CrossSellInfo) -> Bool {
        lhs.id == rhs.id
    }

    public let id: String = UUID().uuidString
    public let type: CrossSellSource
    let additionalInfo: (any Encodable & Sendable)?

    public init<T>(type: CrossSellSource, additionalInfo: T) where T: Encodable & Codable & Sendable {
        self.type = type
        self.additionalInfo = additionalInfo
    }

    public init(type: CrossSellSource) {
        self.type = type
        self.additionalInfo = nil
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
            attributes: self.asLogData()
        )
    }

    public func getCrossSell() async throws -> CrossSells {
        return try await CrossSellService().getCrossSell(source: type)

    }
}
