import Apollo
import Datadog
import Firebase
import Flow
import Foundation
import Mixpanel
import Shake
import hCore
import hGraphQL

public struct AnalyticsCoordinator {
    @Inject private var client: ApolloClient

    public init() {}

    func setUserId() {
        client.fetch(query: GraphQL.MemberIdQuery(), cachePolicy: .fetchIgnoringCacheCompletely)
            .compactMap { $0.member.id }
            .onValue { id in
                Shake.setMetadata(key: "memberId", value: id)
                Mixpanel.mainInstance().identify(distinctId: id)
                Global.rum.addAttribute(forKey: "member_id", value: id)
                Datadog.setUserInfo(id: id)
            }
    }
}
