import Presentation

public enum EditCoInsuredSharedAction: ActionProtocol, Hashable {
    case fetchContracts
    case setActiveContracts(contracts: [Contract])
}

public enum EditCoInsuredSharedLoadingAction: LoadingProtocol {
    case fetchContracts
}
