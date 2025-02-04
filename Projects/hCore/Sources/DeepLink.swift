import Foundation
import hGraphQL

@MainActor
public enum DeepLink: String, Codable, CaseIterable {
    case forever
    case directDebit = "direct-debit"
    case profile
    case insurances
    case home
    case sasEuroBonus = "eurobonus"
    case contract = "contract"
    case payments
    case travelCertificate = "travelCertificate"
    case helpCenter = "help-center"
    case moveContract = "move-contract"
    case changeTier = "change-tier"
    case travelAddon = "travel-addon"
    case terminateContract = "terminate-contract"
    case conversation = "conversation"
    case chat = "chat"
    case inbox = "inbox"
    case contactInfo = "contact-info"

    public func wholeText(displayText: String) -> String {
        return L10n.generalGoTo(displayText.lowercased())
    }

    public var importantText: String {
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
        }
    }
    @MainActor
    public static func getType(from url: URL) -> DeepLink? {
        guard Environment.staging.isDeeplink(url) || Environment.production.isDeeplink(url) else { return nil }
        guard let type = url.pathComponents.compactMap({ DeepLink(rawValue: $0) }).last else {
            return nil
        }
        return type
    }

    public static func getUrl(from deeplink: DeepLink) -> URL? {
        let paths = Environment.current.deepLinkUrls.compactMap({ $0.absoluteString + "/" + deeplink.rawValue })
        let url = paths.compactMap({ URL.init(string: $0) }).last
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
