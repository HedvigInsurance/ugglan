import Apollo
import Firebase
import Flow
import Foundation
import hCore
import hGraphQL
import Mixpanel
import Shake

public struct AnalyticsCoordinator {
    @Inject private var client: ApolloClient

    public init() {}

    func setUserId() {
        client.fetch(
            query: GraphQL.MemberIdQuery(),
            cachePolicy: .fetchIgnoringCacheCompletely
        ).compactMap { $0.member.id }.onValue { id in
            Shake.setMetadata(key: "memberId", value: id)
            Mixpanel.mainInstance().identify(distinctId: id)
        }
    }
}
