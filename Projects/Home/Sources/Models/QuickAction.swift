import Foundation
import hCore

public enum QuickAction: Codable, Equatable, Hashable {
    case sickAbroad(partners: [SickAbroadPartner])
    case firstVet(partners: [FirstVetPartner])
    case editInsurance(actions: [QuickAction])
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
            return "Edit your insurance"
        case .travelInsurance:
            return L10n.hcQuickActionsTravelCertificate
        case .connectPayments:
            return L10n.hcQuickActionsPaymentsTitle
        case .changeAddress:
            return L10n.hcQuickActionsChangeAddressTitle
        case .editCoInsured:
            return L10n.hcQuickActionsCoInsuredTitle
        case .upgradeCoverage:
            return "Upgrade coverage"
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
            return "Manage and update your insurance"
        case .travelInsurance:
            return L10n.hcQuickActionsTravelCertificateSubtitle
        case .connectPayments:
            return L10n.hcQuickActionsPaymentsSubtitle
        case .changeAddress:
            return L10n.hcQuickActionsChangeAddressSubtitle
        case .editCoInsured:
            return L10n.hcQuickActionsCoInsuredSubtitle
        case .upgradeCoverage:
            return "Adjust your insurance after your needs"
        case .cancellation:
            return L10n.hcQuickActionsTerminationSubtitle
        }
    }

    var id: String {
        return displayTitle
    }
}

public struct SickAbroadPartner: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    public let imageUrl: String?
    public let phoneNumber: String?
    public let url: String?
}

public struct FirstVetPartner: Codable, Equatable, Hashable, Identifiable {
    public let id: String
    let buttonTitle: String?
    let description: String?
    let url: String?
    let title: String?
}

extension Sequence where Iterator.Element == QuickAction {
    var hasFirstVet: Bool {
        self.first(where: { $0.isFirstVet }) != nil
    }

    public var getFirstVetPartners: [FirstVetPartner]? {
        return self.first(where: { $0.isFirstVet })?.firstVetPartners
    }

}

extension QuickAction {
    var isFirstVet: Bool {
        switch self {
        case .firstVet:
            return true
        default:
            return false
        }
    }

    public var firstVetPartners: [FirstVetPartner]? {
        switch self {
        case .firstVet(let partners):
            return partners
        default:
            return nil
        }
    }

    public var sickAboardPartners: [SickAbroadPartner]? {
        switch self {
        case .sickAbroad(let partners):
            return partners
        default:
            return nil
        }
    }

}
