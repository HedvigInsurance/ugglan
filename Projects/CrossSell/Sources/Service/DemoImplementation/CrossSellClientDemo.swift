public class CrossSellClientDemo: CrossSellClient {
    public init() {}

    public func getCrossSell() async throws -> [CrossSell] {
        let crossSells: [CrossSell] = [
            .init(title: "title", description: "description", type: .home)
        ]
        return crossSells
    }
}
