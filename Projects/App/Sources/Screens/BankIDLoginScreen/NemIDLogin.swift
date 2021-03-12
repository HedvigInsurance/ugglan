import Apollo
import Flow
import Foundation
import hCore
import hGraphQL
import Presentation
import UIKit

struct NemIDLogin: Presentable {
    @Inject var client: ApolloClient

    func materialize() -> (UIViewController, Future<Void>) {
        let redirectUrl = client.perform(
            mutation: GraphQL.NemIdAuthMutation()
        )
        .compactMap { $0.danishBankIdAuth.redirectUrl }
        .compactMap { URL(string: $0) }

        let didLogin = client.subscribe(subscription: GraphQL.AuthStatusSubscription())
            .compactMap { $0.authStatus?.status }
            .filter(predicate: { status -> Bool in
                status == .success
            })
            .take(first: 1)
            .future
            .toVoid()

        let webViewLogin = WebViewLogin(redirectURL: redirectUrl, didLogin: didLogin)

        return webViewLogin.materialize()
    }
}
