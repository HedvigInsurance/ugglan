import Environment
import Foundation

@MainActor
public enum DeepLink: String, Codable, CaseIterable {
    case forever
    case directDebit = "direct-debit"
    case connectPayment = "connect-payment"
    case connectSwish = "connect-swish"
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
    case puppyGuide = "puppy-guide"
    case moveContract = "move-contract"
    case changeTier = "change-tier"
    case travelAddon = "travel-addon"
    case terminateContract = "terminate-contract"
    case conversation
    case chat
    case inbox
    case contactInfo = "contact-info"
    case editCoInsured = "edit-coinsured"
    case editCoOwners = "edit-coowners"
    case claimDetails = "claim-details"
    case insuranceEvidence = "insurance-evidence"
    case submitClaim = "submit-claim"
    case claimChat = "claim-chat"
    case carPlusAddon = "car-plus-addon"
    case missingPetChipId = "pet-id"
    case payout = "payout"
    case manualCharge = "manual-charge"

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
        case .forever: L10n.tabReferralsTitle
        case .directDebit: L10n.PayInExplainer.buttonText
        case .profile: L10n.tabProfileTitle
        case .insurances: L10n.tabInsurancesTitle
        case .home: L10n.tabHomeTitle
        case .sasEuroBonus: L10n.SasIntegration.title
        case .payments: L10n.myPaymentTitle
        case .contract: L10n.deepLinkContract
        case .travelCertificate: L10n.TravelCertificate.cardTitle
        case .helpCenter: L10n.hcTitle
        case .helpCenterQuestion: L10n.hcQuestionTitle
        case .helpCenterTopic: L10n.hcTitle
        case .puppyGuide: L10n.puppyGuideTitle
        case .moveContract: L10n.InsuranceDetails.changeAddressButton
        case .terminateContract: L10n.hcQuickActionsTerminationTitle
        case .conversation: L10n.chatTitle
        case .contactInfo: L10n.profileMyInfoTitle
        case .chat: L10n.chatConversationInbox
        case .inbox: L10n.chatConversationInbox
        case .changeTier: L10n.InsuranceDetails.changeCoverage
        case .travelAddon: L10n.addonTravelDisplayName
        case .editCoInsured: L10n.hcQuickActionsEditCoinsured
        case .editCoOwners: L10n.editCoownerTitle
        case .claimDetails: L10n.ClaimStatus.ClaimDetails.title
        case .insuranceEvidence: L10n.InsuranceEvidence.documentTitle
        case .submitClaim: L10n.embarkSubmitClaim
        case .carPlusAddon: L10n.addonCarPlusDisplayName
        case .claimChat: L10n.claimChatTitle
        case .missingPetChipId: L10n.chipIdMissingMessage
        case .payout: L10n.payoutPageHeading
        case .manualCharge: L10n.paymentsPaymentOverdueTitle
        case .connectPayment: L10n.paymentConnectTitle
        case .connectSwish: "Swish"
        }
    }

    public var url: URL {
        Environment.current.deepLinkUrl.appendingPathComponent(rawValue)
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
    case sourceMessageId
    case id
    case source
}

extension URL {
    public func getParameter(property: DeeplinkProperty) -> String? {
        guard let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return nil }
        guard let queryItems = urlComponents.queryItems else { return nil }
        return queryItems.first(where: { $0.name == property.rawValue })?.value
    }
}
