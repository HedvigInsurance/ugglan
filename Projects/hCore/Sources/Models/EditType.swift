public enum EditType: String, Codable, Hashable, CaseIterable {
    case changeAddress
    case coInsured
    case changeTier
    case cancellation
    case addon

    public var title: String {
        switch self {
        case .coInsured: return L10n.contractEditCoinsured
        case .changeAddress: return L10n.InsuranceDetails.changeAddressButton
        case .changeTier: return L10n.InsuranceDetails.changeCoverage
        case .cancellation: return L10n.hcQuickActionsCancellationTitle
        case .addon: return "Addon"
        }
    }

    public var subtitle: String {
        switch self {
        case .changeAddress:
            return L10n.hcQuickActionsChangeAddressSubtitle
        case .coInsured:
            return L10n.hcQuickActionsCoInsuredSubtitle
        case .changeTier:
            return L10n.hcQuickActionsUpgradeCoverageSubtitle
        case .cancellation:
            return L10n.hcQuickActionsTerminationSubtitle
        case .addon:
            return "Edit addon"
        }
    }

    public var buttonTitle: String {
        return L10n.generalContinueButton
    }
}
