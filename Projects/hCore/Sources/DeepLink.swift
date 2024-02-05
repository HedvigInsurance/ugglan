import Foundation

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
            return L10n.InsurancesTab.title
        case .home:
            return L10n.HomeTab.title
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
        }
    }

    public static func getType(from url: URL) -> DeepLink? {
        guard let type = url.pathComponents.compactMap({ DeepLink(rawValue: $0) }).first else {
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
