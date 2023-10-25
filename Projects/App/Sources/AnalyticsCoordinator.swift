import Apollo
import Datadog
import Flow
import Foundation
import hCore
import hGraphQL

struct AnalyticsCoordinator {
    @Inject private var octopus: hOctopus

    init() {}

    func setUserId() {
        octopus.client.fetch(query: OctopusGraphQL.CurrentMemberIdQuery(), cachePolicy: .fetchIgnoringCacheCompletely)
            .compactMap { $0.currentMember.id }
            .onValue { id in
                Datadog.setUserInfo(
                    id: id,
                    extraInfo: [
                        "member_id": id
                    ]
                )
            }
    }
}
