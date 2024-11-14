import EditCoInsuredShared
import PresentableStore
import hCoreUI

public enum EditCoInsuredAction: ActionProtocol, Hashable {
    case openEditCoInsured(config: InsuredPeopleConfig, fromInfoCard: Bool)
}

public enum EditCoInsuredLoadingAction: LoadingProtocol {
    case fetchContractBundles
    case fetchContracts
    case postCoInsured
    case fetchNameFromSSN
}

/* TODO: MOVE */
public enum CoInsuredAction: Codable, Identifiable {
    public var id: Self {
        return self
    }

    case delete
    case edit
    case add
}

extension CoInsuredAction: TrackingViewNameProtocol {
    public var nameForTracking: String {
        return .init(describing: SuccessScreen.self)
    }
}
