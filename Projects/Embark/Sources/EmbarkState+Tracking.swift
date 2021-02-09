import Foundation

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

extension EmbarkState {
    func properties(track: EmbarkPassage.Track) -> [String:String]? {
        if track.includeAllKeys {
            return store.revisions.last
        } else {
            return store.revisions.last?.filter { key, value in
                return track.eventKeys.contains(key)
            }
        }
    }
    
    func trackingEvents(from passage: EmbarkPassage) -> [EmbarkTrackingEvent] {
        return passage.tracks
            .map { EmbarkTrackingEvent(title: $0.eventName, properties: properties(track: $0))}
    
    }
}
