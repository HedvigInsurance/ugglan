import EditCoInsuredShared
import Presentation
import hCoreUI

public enum EditCoInsuredAction: ActionProtocol, Hashable {
    case openEditCoInsured(config: InsuredPeopleConfig, fromInfoCard: Bool)
    case performCoInsuredChanges(commitId: String)

    case fetchContracts
    case goToFreeTextChat
}

public enum EditCoInsuredLoadingAction: LoadingProtocol {
    case fetchContractBundles
    case fetchContracts
    case postCoInsured
    case fetchNameFromSSN
}

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
