import Apollo
import Datadog
import Flow
import Foundation
import hCore
import hGraphQL

struct AnalyticsCoordinator {
    @Inject private var giraffe: hGiraffe

    init() {}

    func setUserId() {
        giraffe.client.fetch(query: GiraffeGraphQL.MemberIdQuery(), cachePolicy: .fetchIgnoringCacheCompletely)
            .compactMap { $0.member.id }
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
