import Apollo
import DatadogCore
import Flow
import Foundation
import UIKit
import hCore
import hGraphQL

struct AnalyticsCoordinator {
    @Inject private var octopus: hOctopus

    init() {}

    func setUserId() {
        octopus.client.fetch(query: OctopusGraphQL.CurrentMemberIdQuery(), cachePolicy: .fetchIgnoringCacheCompletely)
            .compactMap { $0.currentMember.id }
            .onValue { id in
                setWith(userId: id)
            }
    }

    func setWith(userId: String?) {
        let deviceModel = UIDevice.current.name
        Datadog.setUserInfo()
        Datadog.setUserInfo(
            id: userId,
            extraInfo: [
                "member_id": userId,
                "deviceModel": deviceModel,
            ]
        )
    }
}
