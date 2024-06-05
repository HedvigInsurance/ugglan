import Apollo
import DatadogCore
import SwiftUI
import hCore
import hGraphQL

public class AnalyticsService {
    @Inject var service: AnalyticsClient

    func fetchAndSetUserId() {
        log.info("AnalyticsService: fetchAndSetUserId", error: nil, attributes: nil)
    }

    func setWith(userId: String) {
        log.info("AnalyticsService: setWith", error: nil, attributes: nil)
    }
}

struct AnalyticsClientOctopus: AnalyticsClient {
    @Inject private var octopus: hOctopus

    init() {}

    func fetchAndSetUserId() {
        octopus.client.fetch(query: OctopusGraphQL.CurrentMemberIdQuery(), cachePolicy: .fetchIgnoringCacheCompletely)
            .compactMap { $0.currentMember.id }
            .onValue { id in
                setWith(userId: id)
            }
    }

    func setWith(userId: String) {
        let deviceModel = UIDevice.modelName
        Datadog.setUserInfo(
            id: userId,
            extraInfo: [
                "device_id": ApolloClient.getDeviceIdentifier(),
                "member_id": userId,
                "device_model": deviceModel,
            ]
        )
    }
}
