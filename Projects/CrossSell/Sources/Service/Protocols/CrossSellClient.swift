@MainActor
public protocol CrossSellClient: Sendable {
    func getCrossSell() async throws -> [CrossSell]
}
