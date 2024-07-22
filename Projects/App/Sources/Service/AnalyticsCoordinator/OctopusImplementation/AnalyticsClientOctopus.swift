import Apollo
import DatadogCore
import SwiftUI
import hCore
import hGraphQL

public class AnalyticsService {
    @Inject var client: AnalyticsClient

    func fetchAndSetUserId() async throws {
        log.info("AnalyticsService: fetchAndSetUserId", error: nil, attributes: nil)
        try await client.fetchAndSetUserId()
    }

    func setWith(userId: String) async throws {
        log.info("AnalyticsService: setWith", error: nil, attributes: nil)
        try await client.setWith(userId: userId)
    }
}

struct AnalyticsClientOctopus: AnalyticsClient {
    @Inject private var octopus: hOctopus

    init() {}

    func fetchAndSetUserId() async throws {
        let data = try await octopus.client.fetch(
            query: OctopusGraphQL.CurrentMemberIdQuery(),
            cachePolicy: .fetchIgnoringCacheCompletely
        )

        setWith(userId: data.currentMember.id)
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
