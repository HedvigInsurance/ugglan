import Presentation

public enum EditCoInsuredAction: ActionProtocol, Hashable {
    case openEditCoInsured(config: InsuredPeopleConfig, fromInfoCard: Bool)
    case coInsuredNavigationAction(action: CoInsuredNavigationAction)
    case performCoInsuredChanges(commitId: String)
    case checkForAlert

    case fetchContracts
    case goToFreeTextChat
}

public enum EditCoInsuredLoadingAction: LoadingProtocol {
    case fetchContractBundles
    case fetchContracts
    case postCoInsured
    case fetchNameFromSSN
}

public enum CoInsuredNavigationAction: ActionProtocol, Hashable {
    case openCoInsuredInput(
        actionType: CoInsuredAction,
        coInsuredModel: CoInsuredModel,
        title: String,
        contractId: String
    )
    case openCoInsuredProcessScreen(showSuccess: Bool)
    case dismissEdit
    case dismissEditCoInsuredFlow
    case openInsuredPeopleNewScreen(config: InsuredPeopleConfig)
    case openInsuredPeopleScreen(config: InsuredPeopleConfig)
    case openCoInsuredSelectScreen(contractId: String)
    case deletionSuccess
    case addSuccess
    case openMissingCoInsuredAlert(config: InsuredPeopleConfig)
    case openErrorScreen
    case openSelectInsuranceScreen(configs: [InsuredPeopleConfig])
}

public enum CoInsuredAction: Codable {
    case delete
    case edit
    case add
}
