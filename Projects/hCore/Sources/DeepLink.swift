import Foundation
import hGraphQL

public enum DeepLink: String, Codable {
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
    case terminateContract = "terminate-contract"
    case openChat = "open-chat"

    public func wholeText(displayText: String) -> String {
        return L10n.generalGoTo(displayText)
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
        case .openChat:
            return L10n.chatTitle
        }
    }

    public static func getType(from url: URL) -> DeepLink? {
        guard let type = url.pathComponents.compactMap({ DeepLink(rawValue: $0) }).first else {
            return nil
        }
        return type
    }

    public static func getUrl(from deeplink: DeepLink) -> URL? {
        let path = Environment.current.deepLinkUrl.absoluteString + "/" + deeplink.rawValue
        guard let url = URL(string: path) else {
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
