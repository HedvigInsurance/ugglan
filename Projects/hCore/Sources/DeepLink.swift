import Foundation

public enum DeepLink: String, Codable {
    case forever
    case directDebit = "direct-debit"
    case profile
    case insurances
    case home
    case sasEuroBonus = "eurobonus"
    case contract = "contract"
}

extension DeepLink {
    var deprecatedTrackingName: String {
        "DEEP_LINK_\(self.rawValue.uppercased())"
    }
}

extension DeepLink {
    var trackingName: String {
        return "DEEP_LINK"
    }
}
