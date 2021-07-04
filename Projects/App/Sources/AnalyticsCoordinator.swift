import Apollo
import Flow
import Foundation
import Mixpanel
import hCore
import hGraphQL

public struct AnalyticsCoordinator {
	@Inject private var client: ApolloClient

	public init() {}

	func setUserId() {
		client.fetch(query: GraphQL.MemberIdQuery(), cachePolicy: .fetchIgnoringCacheCompletely)
			.compactMap { $0.member.id }
			.onValue { id in
				#if canImport(Shake)
					Shake.setMetadata(key: "memberId", value: id)
				#endif
				Mixpanel.mainInstance().identify(distinctId: id)
			}
	}
}
