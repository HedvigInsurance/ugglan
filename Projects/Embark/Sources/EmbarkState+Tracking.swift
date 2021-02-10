import Foundation
import hGraphQL

public struct EmbarkTrackingEvent {
    var title: String
    var properties: [String:String]?
    
    func send() {
        Self.trackingHandler(self)
    }
}

extension EmbarkTrackingEvent {
    public static var trackingHandler: (_ Event: EmbarkTrackingEvent) -> Void = { _ in }
}

internal extension GraphQL.EmbarkExternalRedirectLocation {
    func trackingEvent(store: EmbarkStore) -> EmbarkTrackingEvent {
        var properties = [String:String]()
        if let store = store.revisions.last {
            properties = store
        }
        properties["redirectLocation"] = self.rawValue
        return EmbarkTrackingEvent(title: "External Redirect", properties: properties)
    }
}

internal extension EmbarkPassage.Track {
    func trackingEvent(store: EmbarkStore) -> EmbarkTrackingEvent {
        return .init(title: self.eventName, properties: properties(store: store))
    }
    
    private func properties(store: EmbarkStore) -> [String:String]? {
        if includeAllKeys {
            return store.revisions.last
        } else {
            return store.revisions.last?.filter { key, value in
                return eventKeys.contains(key)
            }
        }
    }
}

extension EmbarkState {
    func trackGoBack() {
        EmbarkTrackingEvent(title: "Passage go back - \(currentPassageSignal.value?.name ?? "")", properties: nil).send()
    }
}
