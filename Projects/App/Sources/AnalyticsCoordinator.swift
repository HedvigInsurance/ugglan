import Apollo
import DatadogCore
import Foundation
import SwiftUI
import hCore
import hGraphQL

protocol AnalyticsService {
    func fetchAndSetUserId()
    func setWith(userId: String)
}

struct AnalyticsServiceDemo: AnalyticsService {
    func fetchAndSetUserId() {}
    func setWith(userId: String) {}
}

struct AnalyticsServiceOctopus: AnalyticsService {
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
