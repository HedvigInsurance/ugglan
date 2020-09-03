//
//  AnalyticsCoordinator.swift
//  test
//
//  Created by Sam Pettersson on 2019-09-27.
//

import Apollo
import Firebase
import Flow
import Foundation
import hCore
import hGraphQL
import Mixpanel

public struct AnalyticsCoordinator {
    @Inject private var client: ApolloClient

    public init() {}

    func setUserId() {
        client.fetch(
            query: GraphQL.MemberIdQuery(),
            cachePolicy: .fetchIgnoringCacheCompletely
        ).compactMap { $0.member.id }.onValue { id in
            Mixpanel.mainInstance().identify(distinctId: id)
        }
    }
}
