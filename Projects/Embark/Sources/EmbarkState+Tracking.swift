import Foundation
import hAnalytics
import hCore
import hGraphQL

extension EmbarkPassage.Track {
    func send(storyName: String, storeValues: [String: String?]) {
        hAnalyticsEvent.embarkTrack(
            storyName: storyName,
            eventName: eventName,
            store: trackingProperties(storyName: storyName, storeValues: storeValues)
        )
        .send()
    }

    private func trackingProperties(storyName: String, storeValues: [String: String?]) -> [String: String?] {
        var filteredProperties = storeValues.filter { key, _ in eventKeys.contains(key) }

        if let customData = customData {
            filteredProperties =
                filteredProperties.merging(
                    (customData.toJSONDictionary() ?? [:])
                        .mapValues({ any in
                            any as? String
                        }),
                    uniquingKeysWith: takeRight
                )
        }

        return filteredProperties
    }
}

extension EmbarkState {
    func trackGoBack() {
        hAnalyticsEvent.embarkPassageGoBack(
            storyName: storySignal.value?.name ?? "",
            passageName: currentPassageSignal.value?.name ?? ""
        )
        .send()
    }
}
