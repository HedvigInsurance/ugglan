import EditCoInsuredShared
import Presentation

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
