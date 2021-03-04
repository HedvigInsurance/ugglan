import Foundation
import hGraphQL
import hCore

public struct EmbarkTrackingEvent {
    public var title: String
    public var properties: [String:Any]
    
    func send() {
        Self.trackingHandler(self)
    }
}

public extension EmbarkTrackingEvent {
    static var trackingHandler: (_ Event: EmbarkTrackingEvent) -> Void = { _ in }
}

internal extension GraphQL.EmbarkExternalRedirectLocation {
    func trackingEvent(storeValues: [String:Any]) -> EmbarkTrackingEvent {
        var trackingProperties = storeValues
        trackingProperties["redirectLocation"] = self.rawValue
        return EmbarkTrackingEvent(title: "External Redirect", properties: trackingProperties)
    }
}

internal extension EmbarkPassage.Track {
    func trackingEvent(storeValues: [String:Any]) -> EmbarkTrackingEvent {
        return .init(title: self.eventName, properties: trackingProperties(storeValues: storeValues))
    }
    
    private func trackingProperties(storeValues: [String:Any]) -> [String:Any] {
        var filteredProperties = storeValues.filter { key, value in
            return eventKeys.contains(key)
        }
        
        if let customData = customData {
            filteredProperties = filteredProperties.merging((customData.toJSONDictionary() ?? [:]), uniquingKeysWith: takeRight)
        }
        
        return filteredProperties
    }
}

extension EmbarkState {
    func trackGoBack() {
        EmbarkTrackingEvent(title: "Passage go back - \(currentPassageSignal.value?.name ?? "")", properties: [:]).send()
    }
}
