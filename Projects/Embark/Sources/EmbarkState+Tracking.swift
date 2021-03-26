import Foundation
import hCore
import hGraphQL

public struct EmbarkTrackingEvent {
    public var title: String
    public var properties: [String: Any]

    func send() {
        Self.trackingHandler(self)
    }
}

public extension EmbarkTrackingEvent {
    static var trackingHandler: (_ Event: EmbarkTrackingEvent) -> Void = { _ in }
}

internal extension GraphQL.EmbarkExternalRedirectLocation {
    func trackingEvent(storeValues: [String: Any]) -> EmbarkTrackingEvent {
        var trackingProperties = storeValues
        trackingProperties["redirectLocation"] = rawValue
        return EmbarkTrackingEvent(title: "External Redirect", properties: trackingProperties)
    }
}

internal extension EmbarkPassage.Track {
    func trackingEvent(storeValues: [String: Any]) -> EmbarkTrackingEvent {
        .init(title: eventName, properties: trackingProperties(storeValues: storeValues))
    }

    private func trackingProperties(storeValues: [String: Any]) -> [String: Any] {
        var filteredProperties = storeValues.filter { key, _ in
            eventKeys.contains(key)
        }

        if let customData = customData {
            filteredProperties = filteredProperties.merging(customData.toJSONDictionary() ?? [:], uniquingKeysWith: takeRight)
        }

        return filteredProperties
    }
}

extension EmbarkState {
    func trackGoBack() {
        EmbarkTrackingEvent(title: "Passage go back - \(currentPassageSignal.value?.name ?? "")", properties: [:]).send()
    }
}
