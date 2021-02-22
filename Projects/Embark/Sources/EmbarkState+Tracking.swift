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
    func trackingEvent(store: EmbarkStore) -> EmbarkTrackingEvent {
        var properties = store.getAllValues()
        properties["redirectLocation"] = self.rawValue
        return EmbarkTrackingEvent(title: "External Redirect", properties: properties)
    }
}

internal extension EmbarkPassage.Track {
    func trackingEvent(store: EmbarkStore) -> EmbarkTrackingEvent {
        return .init(title: self.eventName, properties: properties(store: store))
    }
    
    private func properties(store: EmbarkStore) -> [String:Any] {
        var properties = Dictionary<String,Any>()
        if includeAllKeys {
            properties = properties.merging((store.getAllValues())) { return $1 }
        } else {
            let storeProperties = store.getAllValues().filter { key, value in
                return eventKeys.contains(key)
            }
            
            properties = properties.merging(storeProperties, uniquingKeysWith: { return $1 })
        }
        
        if let customData = customData {
            properties = properties.merging((customData.toJSONDictionary() ?? [:]), uniquingKeysWith: { return $1 })
        }
        
        return properties
    }
}

extension EmbarkState {
    func trackGoBack() {
        EmbarkTrackingEvent(title: "Passage go back - \(currentPassageSignal.value?.name ?? "")", properties: [:]).send()
    }
}
