//
//  AnalyticsCoordinator.swift
//  test
//
//  Created by Sam Pettersson on 2019-09-27.
//

import Apollo
import Flow
import Foundation
import hCore
import Mixpanel

public struct AnalyticsCoordinator {
    @Inject private var client: ApolloClient

    public init() {}

    func setUserId() {
        client.fetch(
            query: MemberIdQuery(),
            cachePolicy: .fetchIgnoringCacheCompletely
        ).map { $0.data?.member.id }.onValue { id in
            guard let id = id else {
                return
            }

            Mixpanel.mainInstance().identify(distinctId: id)
        }
    }
}
