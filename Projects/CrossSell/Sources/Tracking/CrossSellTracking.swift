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

    /// The offer is described by its backend id (`crossSell:ACCIDENT`), the campaign code its store link applies and
    /// the experiment groups the backend made it for, never by the link itself: Firebase drops parameter values over
    /// 100 characters. The link lists each group as `attribution.experiments.ACCIDENT_DISCOUNT=NO_DISCOUNT`, and
    /// each becomes a parameter named after the experiment.
    func analyticsParameters(from source: CrossSellSource) -> [String: String] {
        var parameters = ["user_flow": source.analyticsUserFlow, "offer_id": id]
        if let campaignCode {
            parameters["campaign_code"] = campaignCode
        }
        parameters.merge(experiments) { own, _ in own }
        return parameters
    }

    var campaignCode: String? {
        storeLinkParameters["code"]
    }

    /// The experiment groups in the store link, keyed by experiment, leaving out names Firebase would reject as
    /// parameters.
    var experiments: [String: String] {
        var experiments: [String: String] = [:]
        for (name, variant) in storeLinkParameters where name.hasPrefix(experimentParameterPrefix) {
            let experiment = String(name.dropFirst(experimentParameterPrefix.count))
            if experiment.range(of: "^[A-Za-z][A-Za-z0-9_]{0,39}$", options: .regularExpression) != nil {
                experiments[experiment] = variant
            }
        }
        return experiments
    }

    /// Each named query parameter's first non-empty value, decoded.
    private var storeLinkParameters: [String: String] {
        guard let webActionURL, let components = URLComponents(string: webActionURL) else { return [:] }
        var parameters: [String: String] = [:]
        for item in components.queryItems ?? [] where parameters[item.name] == nil {
            if let value = item.value, !value.isEmpty {
                parameters[item.name] = value
            }
        }
        return parameters
    }
}

private let experimentParameterPrefix = "attribution.experiments."

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
