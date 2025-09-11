import Environment
import Foundation

@MainActor
public enum DeepLink: String, Codable, CaseIterable {
    case forever
    case directDebit = "direct-debit"
    case profile
    case insurances
    case home
    case sasEuroBonus = "eurobonus"
    case contract
    case payments
    case travelCertificate
    case helpCenter = "help-center"
    case helpCenterTopic = "help-center/topic"
    case helpCenterQuestion = "help-center/question"
    case moveContract = "move-contract"
    case changeTier = "change-tier"
    case travelAddon = "travel-addon"
    case terminateContract = "terminate-contract"
    case conversation
    case chat
    case inbox
    case contactInfo = "contact-info"
    case editCoInsured = "edit-coinsured"
    case claimDetails = "claim-details"
    case insuranceEvidence = "insurance-evidence"
    case submitClaim = "submit-claim"

    public func getDeeplinkTextFor(contractName: String?) -> String {
        switch self {
        case .terminateContract:
            if let contractName {
                return L10n.chatConversationTerminateContract(contractName)
            }
            return L10n.generalGoTo(importantText)
        default:
            return L10n.generalGoTo(contractName ?? importantText)
        }
    }

    var importantText: String {
        switch self {
        case .forever:
            return L10n.tabReferralsTitle
        case .directDebit:
            return L10n.PayInExplainer.buttonText
        case .profile:
            return L10n.tabProfileTitle
        case .insurances:
            return L10n.tabInsurancesTitle
        case .home:
            return L10n.tabHomeTitle
        case .sasEuroBonus:
            return L10n.SasIntegration.title
        case .payments:
            return L10n.myPaymentTitle
        case .contract:
            return L10n.deepLinkContract
        case .travelCertificate:
            return L10n.TravelCertificate.cardTitle
        case .helpCenter:
            return L10n.hcTitle
        case .helpCenterQuestion:
            return L10n.hcQuestionTitle
        case .helpCenterTopic:
            return L10n.hcTitle
        case .moveContract:
            return L10n.InsuranceDetails.changeAddressButton
        case .terminateContract:
            return L10n.hcQuickActionsTerminationTitle
        case .conversation:
            return L10n.chatTitle
        case .contactInfo:
            return L10n.profileMyInfoTitle
        case .chat:
            return L10n.chatConversationInbox
        case .inbox:
            return L10n.chatConversationInbox
        case .changeTier:
            return L10n.InsuranceDetails.changeCoverage
        case .travelAddon:
            return L10n.addonTravelDisplayName
        case .editCoInsured:
            return L10n.hcQuickActionsEditCoinsured
        case .claimDetails:
            return L10n.ClaimStatus.ClaimDetails.title
        case .insuranceEvidence:
            return L10n.InsuranceEvidence.documentTitle
        case .submitClaim:
            return L10n.embarkSubmitClaim
        }
    }

    @MainActor
    public static func getType(from url: URL) -> DeepLink? {
        guard Environment.staging.isDeeplink(url) || Environment.production.isDeeplink(url) else { return nil }
        let components = url.pathComponents.filter { $0 != "/" }.filter { $0 != "deeplink" }.joined(separator: "/")

        guard let type = DeepLink(rawValue: components) else {
            return nil
        }
        return type
    }

    public static func getUrl(from deeplink: DeepLink) -> URL? {
        let paths = Environment.current.deepLinkUrls.compactMap { $0.absoluteString + "/" + deeplink.rawValue }
        let url = paths.compactMap { URL(string: $0) }.last
        guard let url else {
            return nil
        }
        return url
    }

    public var tabURL: Bool {
        switch self {
        case .forever, .insurances, .home, .helpCenter:
            return true
        default:
            return false
        }
    }
}

public enum DeeplinkProperty: String {
    case contractId
    case conversationId
    case claimId
    case id
}

extension URL {
    public func getParameter(property: DeeplinkProperty) -> String? {
        guard let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return nil }
        guard let queryItems = urlComponents.queryItems else { return nil }
        return queryItems.first(where: { $0.name == property.rawValue })?.value
    }
}
