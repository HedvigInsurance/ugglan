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
    /// Sends the member to the web store, counting a click only when the system opened it.
    @MainActor
    @discardableResult
    public func openStore() async -> Bool {
        guard let webActionURL, let url = URL(string: webActionURL) else { return false }
        let opened = await Dependencies.urlOpener.open(url)
        if opened {
            track(.clicked)
        }
        return opened
    }

    @MainActor
    public func track(_ event: CrossSellEvent) {
        // Previews register no event tracking client to report to.
        guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else { return }
        let eventTrackingClient: EventTrackingClient = Dependencies.shared.resolve()
        eventTrackingClient.trackEvent(name: event.rawValue, parameters: analyticsParameters)
    }

    /// The offer is described by its backend id (`crossSell:ACCIDENT`), the campaign code its store link applies and
    /// the experiment groups the backend made it for, never by the link itself: Firebase drops parameter values over
    /// 100 characters.
    var analyticsParameters: [String: String] {
        let storeLink = StoreLinkAttribution(webActionURL)
        var parameters = ["user_flow": source.analyticsUserFlow, "offer_id": id]
        if let campaignCode = storeLink.campaignCode {
            parameters["campaign_code"] = campaignCode
        }
        parameters.merge(storeLink.experiments) { own, _ in own }
        return parameters
    }

    var campaignCode: String? {
        StoreLinkAttribution(webActionURL).campaignCode
    }

    var experiments: [String: String] {
        StoreLinkAttribution(webActionURL).experiments
    }
}

extension RecommendedCrossSell {
    /// Add-on recommendations are not tracked as cross-sells.
    @MainActor
    public func track(_ event: CrossSellEvent) {
        if case let .insurance(crossSell) = self {
            crossSell.track(event)
        }
    }
}

/// What a store link says about the offer, read from its query in one pass.
private struct StoreLinkAttribution {
    private static let experimentPrefix = "attribution.experiments."

    /// The campaign code the store applies.
    private(set) var campaignCode: String?
    /// The experiment groups, keyed by experiment. The link lists each as
    /// `attribution.experiments.ACCIDENT_DISCOUNT=NO_DISCOUNT`; names Firebase would reject as parameters are left out.
    private(set) var experiments: [String: String] = [:]

    init(_ webActionURL: String?) {
        guard let webActionURL, let components = URLComponents(string: webActionURL) else { return }
        var seen = Set<String>()
        // The first non-empty occurrence of a parameter wins.
        for item in components.queryItems ?? [] {
            guard let value = item.value, !value.isEmpty, seen.insert(item.name).inserted else { continue }
            if item.name == "code" {
                campaignCode = value
            } else if item.name.hasPrefix(Self.experimentPrefix) {
                let experiment = String(item.name.dropFirst(Self.experimentPrefix.count))
                if Self.isValidParameterName(experiment) {
                    experiments[experiment] = value
                }
            }
        }
    }

    /// Firebase parameter names: up to 40 ASCII letters, digits and underscores, starting with a letter.
    private static func isValidParameterName(_ name: String) -> Bool {
        guard let first = name.first, first.isASCII, first.isLetter, name.count <= 40 else { return false }
        return name.allSatisfy { $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "_") }
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
