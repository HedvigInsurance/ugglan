import Foundation

public struct AnalyticsSender {
    /// The function that is called when a tracking event should be sent
    /// Use this to integrate with analytics provider
    public static var sendEvent: (_ name: String, _ properties: [String: AnalyticsProperty]) -> Void = { _, _ in }
}

public enum AnalyticsCommonEventName: String {
    case buttonClick = "BUTTON_CLICK"
}

public struct Analytics {
    /// Send a tracking event
    public static func track(_ name: String, properties: [String: AnalyticsProperty]) {
        AnalyticsSender.sendEvent(name, properties)
    }

    /// Send a tracking event with a commonly defined name
    public static func track(_ name: AnalyticsCommonEventName, properties: [String: AnalyticsProperty]) {
        AnalyticsSender.sendEvent(name.rawValue, properties)
    }
}

public protocol AnalyticsProperty {}

extension Array: AnalyticsProperty where Element: AnalyticsProperty {}
extension String: AnalyticsProperty {}
extension Float: AnalyticsProperty {}
extension Int: AnalyticsProperty {}
extension Date: AnalyticsProperty {}
