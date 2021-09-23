import Foundation
import hCore
import hGraphQL

extension EmbarkPassage.Track {
    func send(storyName: String, storeValues: [String: Any]) {
        Analytics.track(eventName, properties: trackingProperties(storyName: storyName, storeValues: storeValues))
    }

    private func trackingProperties(storyName: String, storeValues: [String: Any]) -> [String: AnalyticsProperty] {
        var filteredProperties = storeValues.filter { key, _ in eventKeys.contains(key) }

        if let customData = customData {
            filteredProperties = filteredProperties.merging(
                customData.toJSONDictionary() ?? [:],
                uniquingKeysWith: takeRight
            )
        }
        
        filteredProperties = filteredProperties.merging(
            ["originatedFromEmbarkStory": storyName],
            uniquingKeysWith: takeRight
        )

        return filteredProperties.mapValues { any in
            any as? AnalyticsProperty
        }
        .compactMapValues { $0 }
    }
}

extension EmbarkState {
    func trackGoBack() {
        Analytics.track(
            "Passage go back - \(currentPassageSignal.value?.name ?? "")",
            properties: [:]
        )
    }
}
