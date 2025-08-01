import Foundation
import hCore

public enum QuickAction: Codable, Equatable, Hashable, Sendable {
    case sickAbroad(partners: [SickAbroadPartner])
    case firstVet(partners: [FirstVetPartner])
    case editInsurance(actions: EditInsuranceActionsWrapper)
    case travelInsurance
    case connectPayments
    case changeAddress
    case editCoInsured
    case upgradeCoverage
    case cancellation

    public var displayTitle: String {
        switch self {
        case .sickAbroad:
            return L10n.hcQuickActionsSickAbroadTitle
        case .firstVet:
            return L10n.hcQuickActionsFirstvetTitle
        case .editInsurance:
            return L10n.hcQuickActionsEditInsuranceTitle
        case .travelInsurance:
            return L10n.hcQuickActionsTravelCertificate
        case .connectPayments:
            return L10n.hcQuickActionsPaymentsTitle
        case .changeAddress:
            return L10n.hcQuickActionsChangeAddressTitle
        case .editCoInsured:
            return L10n.hcQuickActionsCoInsuredTitle
        case .upgradeCoverage:
            return L10n.hcQuickActionsUpgradeCoverageTitle
        case .cancellation:
            return L10n.hcQuickActionsTerminationTitle
        }
    }

    public var displaySubtitle: String {
        switch self {
        case .sickAbroad:
            return L10n.hcQuickActionsSickAbroadSubtitle
        case .firstVet:
            return L10n.hcQuickActionsFirstvetSubtitle
        case .editInsurance:
            return L10n.hcQuickActionsEditInsuranceSubtitle
        case .travelInsurance:
            return L10n.hcQuickActionsTravelCertificateSubtitle
        case .connectPayments:
            return L10n.hcQuickActionsPaymentsSubtitle
        case .changeAddress:
            return L10n.hcQuickActionsChangeAddressSubtitle
        case .editCoInsured:
            return L10n.hcQuickActionsCoInsuredSubtitle
        case .upgradeCoverage:
            return L10n.hcQuickActionsUpgradeCoverageSubtitle
        case .cancellation:
            return L10n.hcQuickActionsTerminationSubtitle
        }
    }

    var id: String {
        displayTitle
    }
}

extension QuickAction {
    var asEditType: EditType? {
        switch self {
        case .sickAbroad:
            return nil
        case .firstVet:
            return nil
        case .editInsurance:
            return nil
        case .travelInsurance:
            return nil
        case .connectPayments:
            return nil
        case .changeAddress:
            return .changeAddress
        case .editCoInsured:
            return .coInsured
        case .upgradeCoverage:
            return .changeTier
        case .cancellation:
            return .cancellation
        }
    }
}

extension EditType {
    var asQuickAction: QuickAction {
        switch self {
        case .changeAddress:
            return .changeAddress
        case .coInsured:
            return .editCoInsured
        case .changeTier:
            return .upgradeCoverage
        case .cancellation:
            return .cancellation
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

public struct SickAbroadPartner: Codable, Equatable, Hashable, Identifiable, Sendable {
    public let id: String
    public let imageUrl: String?
    public let phoneNumber: String?
    public let url: String?
    public let preferredImageHeight: Int?

    public init(id: String, imageUrl: String?, phoneNumber: String?, url: String?, preferredImageHeight: Int?) {
        self.id = id
        self.imageUrl = imageUrl
        self.phoneNumber = phoneNumber
        self.url = url
        self.preferredImageHeight = preferredImageHeight
    }
}

public struct FirstVetPartner: Codable, Equatable, Hashable, Identifiable, Sendable {
    public let id: String
    let buttonTitle: String?
    let description: String?
    let url: String?
    let title: String?

    public init(id: String, buttonTitle: String?, description: String?, url: String?, title: String?) {
        self.id = id
        self.buttonTitle = buttonTitle
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

public extension QuickAction {
    internal var isFirstVet: Bool {
        switch self {
        case .firstVet:
            return true
        default:
            return false
        }
    }

    var firstVetPartners: [FirstVetPartner]? {
        switch self {
        case let .firstVet(partners):
            return partners
        default:
            return nil
        }
    }

    var sickAboardPartners: [SickAbroadPartner]? {
        switch self {
        case let .sickAbroad(partners):
            return partners
        default:
            return nil
        }
    }
}
