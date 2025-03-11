import PresentableStore

public enum CrossSellAction: ActionProtocol, Hashable {
    case fetchCrossSell
    case setCrossSells(crossSells: [CrossSell])
}

public enum CrossSellLoadingAction: LoadingProtocol {
    case fetchCrossSell
}
