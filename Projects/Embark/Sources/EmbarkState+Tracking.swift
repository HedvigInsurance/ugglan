import Foundation
import hCore
import hGraphQL
import hAnalytics

extension EmbarkPassage.Track {
    func send(storyName: String, storeValues: [String: Any]) {
        Analytics.track(eventName, properties: trackingProperties(storyName: storyName, storeValues: storeValues))
        hAnalyticsEvent.embarkTrack(
            storyName: storyName,
            eventName: eventName,
            store: trackingProperties(storyName: storyName, storeValues: storeValues)
        ).send()
    }

    private func trackingProperties(storyName: String, storeValues: [String: Any]) -> [String: AnalyticsProperty] {
        var filteredProperties = storeValues.filter { key, _ in eventKeys.contains(key) }

        if let customData = customData {
            filteredProperties =
                filteredProperties.merging(
                    customData.toJSONDictionary() ?? [:],
                    uniquingKeysWith: takeRight
                )
                .compactMapValues { value in
                    value as? String
                }
        }

        filteredProperties = filteredProperties.merging(
            ["originatedFromEmbarkStory": storyName],
            uniquingKeysWith: takeRight
        )

        return
            filteredProperties.mapValues { any in
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
        Analytics.track(
            "passage_go_back",
            properties: [
                "passageName": currentPassageSignal.value?.name ?? "",
                "originatedFromEmbarkStory": storySignal.value?.name ?? "",
            ]
        )
        
        hAnalyticsEvent.embarkPassageGoBack(
            storyName: storySignal.value?.name ?? "",
            passageName: currentPassageSignal.value?.name ?? ""
        ).send()
    }
}
