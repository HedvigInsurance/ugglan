import Apollo
import Datadog
import Flow
import Foundation
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
                Shake.setMetadata(
                    key: "locale",
                    value: Localization.Locale.currentLocale.lprojCode
                )
                Datadog.setUserInfo(
                    id: id,
                    extraInfo: [
                        "member_id": id
                    ]
                )
            }
    }
}
