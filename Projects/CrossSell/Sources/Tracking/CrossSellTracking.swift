import Foundation
import hCore

/// The Firebase events that let analytics compare what members are offered, take and turn down.
/// Names and parameters match Android's, so one query answers for both apps.
public enum CrossSellEvent: String, Sendable {
    case shown = "cross_sell_shown"
    case clicked = "cross_sell_clicked"
    case dismissed = "cross_sell_dismissed"
}

extension CrossSell {
    @MainActor
    public func track(_ event: CrossSellEvent, from source: CrossSellSource) {
        let eventTrackingClient: EventTrackingClient = Dependencies.shared.resolve()
        eventTrackingClient.trackEvent(name: event.rawValue, parameters: analyticsParameters(from: source))
    }

    /// The offer is described by its backend id (`crossSell:ACCIDENT`) and the campaign code its store link
    /// applies, never by the link itself: Firebase drops parameter values over 100 characters.
    func analyticsParameters(from source: CrossSellSource) -> [String: String] {
        var parameters = ["user_flow": source.analyticsUserFlow, "offer_id": id]
        if let campaignCode {
            parameters["campaign_code"] = campaignCode
        }
        return parameters
    }

    var campaignCode: String? {
        guard let webActionURL, let components = URLComponents(string: webActionURL) else { return nil }
        let code = components.queryItems?.first { $0.name == "code" }?.value
        return code?.isEmpty == false ? code : nil
    }
}

extension CrossSellSource {
    /// The backend `UserFlow` this source requests its offers with, lowercased.
    var analyticsUserFlow: String {
        switch self {
        case .homeXSell: "home_x_sell"
        case .closedClaim, .changeTier, .addon, .movingFlow: "smart_x_sell"
        case .home: "home"
        case .insurances: "insurances"
        case .onboarding: "onboarding"
        case .inChat: "in_chat_x_sell"
        }
    }
}
