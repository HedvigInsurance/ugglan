public enum EditType: String, Codable, Hashable, CaseIterable {
    case changeAddress
    case coInsured
    case coOwners
    case changeTier
    case cancellation
    case removeAddons

    public var title: String {
        switch self {
        case .coInsured: return L10n.contractEditCoinsured
        case .coOwners: return L10n.editCoownerTitle
        case .changeAddress: return L10n.InsuranceDetails.changeAddressButton
        case .changeTier: return L10n.InsuranceDetails.changeCoverage
        case .cancellation: return L10n.hcQuickActionsCancellationTitle
        case .removeAddons: return L10n.removeAddonButtonTitle
        }
    }

    public var subtitle: String {
        switch self {
        case .changeAddress: return L10n.hcQuickActionsChangeAddressSubtitle
        case .coInsured: return L10n.hcQuickActionsCoInsuredSubtitle
        case .coOwners: return L10n.editCoownerSubtitle
        case .changeTier: return L10n.hcQuickActionsUpgradeCoverageSubtitle
        case .cancellation: return L10n.hcQuickActionsTerminationSubtitle
        case .removeAddons: return L10n.hcQuickActionsRemoveAddonSubtitle
        }
    }

    public var buttonTitle: String {
        L10n.generalContinueButton
    }
}
