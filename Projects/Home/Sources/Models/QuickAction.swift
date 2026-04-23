import Foundation
import SubmitClaimChat
import hCore

public enum QuickAction: Codable, Equatable, Hashable, Sendable {
    case sickAbroad(deflection: Deflection)
    case firstVet(partners: [FirstVetPartner])
    case editInsurance(actions: EditInsuranceActionsWrapper)
    case travelInsurance
    case connectPayments
    case changeAddress
    case editCoInsured
    case editCoOwners
    case upgradeCoverage
    case cancellation
    case removeAddons

    public var displayTitle: String {
        switch self {
        case .sickAbroad: L10n.hcQuickActionsSickAbroadTitle
        case .firstVet: L10n.hcQuickActionsFirstvetTitle
        case .editInsurance: L10n.hcQuickActionsEditInsuranceTitle
        case .travelInsurance: L10n.hcQuickActionsTravelCertificate
        case .connectPayments: L10n.hcQuickActionsPaymentsTitle
        case .changeAddress: L10n.hcQuickActionsChangeAddressTitle
        case .editCoInsured: L10n.hcQuickActionsCoInsuredTitle
        case .editCoOwners: L10n.editCoownerSubtitle  // TODO: use lokalise hcQuickAction?
        case .upgradeCoverage: L10n.hcQuickActionsUpgradeCoverageTitle
        case .cancellation: L10n.hcQuickActionsTerminationTitle
        case .removeAddons: L10n.removeAddonButtonTitle
        }
    }

    public var displaySubtitle: String {
        switch self {
        case .sickAbroad: L10n.hcQuickActionsSickAbroadSubtitle
        case .firstVet: L10n.hcQuickActionsFirstvetSubtitle
        case .editInsurance: L10n.hcQuickActionsEditInsuranceSubtitle
        case .travelInsurance: L10n.hcQuickActionsTravelCertificateSubtitle
        case .connectPayments: L10n.hcQuickActionsPaymentsSubtitle
        case .changeAddress: L10n.hcQuickActionsChangeAddressSubtitle
        case .editCoInsured: L10n.hcQuickActionsCoInsuredSubtitle
        case .editCoOwners: L10n.editCoownerSubtitle  // TODO: use lokalise hcQuickAction?
        case .upgradeCoverage: L10n.hcQuickActionsUpgradeCoverageSubtitle
        case .cancellation: L10n.hcQuickActionsTerminationSubtitle
        case .removeAddons: L10n.hcQuickActionsRemoveAddonSubtitle
        }
    }

    var id: String {
        displayTitle
    }
}

extension QuickAction {
    var asEditType: EditType? {
        switch self {
        case .sickAbroad: nil
        case .firstVet: nil
        case .editInsurance: nil
        case .travelInsurance: nil
        case .connectPayments: nil
        case .changeAddress: .changeAddress
        case .editCoInsured: .coInsured
        case .editCoOwners: .coOwners
        case .upgradeCoverage: .changeTier
        case .cancellation: .cancellation
        case .removeAddons: .removeAddons
        }
    }
}

extension EditType {
    var asQuickAction: QuickAction {
        switch self {
        case .changeAddress: .changeAddress
        case .coInsured: .editCoInsured
        case .coOwners: .editCoOwners
        case .changeTier: .upgradeCoverage
        case .cancellation: .cancellation
        case .removeAddons: .removeAddons
        }
    }
}

public struct EditInsuranceActionsWrapper: Codable, Equatable, Hashable, Identifiable, Sendable {
    public let id: String
    let quickActions: [QuickAction]

    public init(quickActions: [QuickAction]) {
        id = quickActions.compactMap(\.id).joined(separator: ",")
        self.quickActions = quickActions
    }
}

public struct FirstVetPartner: Codable, Equatable, Hashable, Identifiable, Sendable {
    public let id: String
    let description: String?
    let url: String?
    let title: String?

    public init(id: String, description: String?, url: String?, title: String?) {
        self.id = id
        self.description = description
        self.url = url
        self.title = title
    }
}

extension Sequence where Iterator.Element == QuickAction {
    var hasFirstVet: Bool {
        first(where: { $0.isFirstVet }) != nil
    }

    public var getFirstVetPartners: [FirstVetPartner]? {
        first(where: { $0.isFirstVet })?.firstVetPartners
    }
}

extension QuickAction {
    internal var isFirstVet: Bool {
        switch self {
        case .firstVet: true
        default: false
        }
    }

    public var firstVetPartners: [FirstVetPartner]? {
        switch self {
        case let .firstVet(partners): partners
        default: nil
        }
    }
}
