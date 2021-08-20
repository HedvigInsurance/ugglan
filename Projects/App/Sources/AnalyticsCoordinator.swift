import Apollo
import Firebase
import Flow
import Foundation
import Mixpanel
import Shake
import hCore
import hGraphQL
import Datadog

public struct AnalyticsCoordinator {
    @Inject private var client: ApolloClient

    public init() {}

    func setUserId() {
        client.fetch(query: GraphQL.MemberIdQuery(), cachePolicy: .fetchIgnoringCacheCompletely)
            .compactMap { $0.member.id }
            .onValue { id in
                Shake.setMetadata(key: "memberId", value: id)
                Mixpanel.mainInstance().identify(distinctId: id)
                Global.rum.addAttribute(forKey: "memberId", value: id)
                Global.rum.addAttribute(forKey: "usr.id", value: id)
            }
    }
}
