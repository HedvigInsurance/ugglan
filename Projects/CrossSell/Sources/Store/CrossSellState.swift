import PresentableStore

public struct CrossSellState: StateProtocol {
    public init() {}

    public var crossSells: [CrossSell] = []
}
