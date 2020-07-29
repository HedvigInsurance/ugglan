//
//  AppDelegate.swift
//
//
//  Created by Sam Pettersson on 2020-05-06.
//

import Apollo
import ApolloWebSocket
import Embark
import Flow
import Foundation
import hCore
import Presentation
import UIKit

extension ApolloClient {
    static func createClient(token _: String?) -> (ApolloStore, ApolloClient) {
        let httpAdditionalHeaders = [
            "Authorization": "tBmMTBw4OAPC5w==.TNrYtXtgMrDzxw==.KyJBBOTLaw1/Pg==",
            "User-Agent": "iOS",
        ]

        let configuration = URLSessionConfiguration.default

        configuration.httpAdditionalHeaders = httpAdditionalHeaders

        let urlSessionClient = URLSessionClient(sessionConfiguration: configuration)

        let httpNetworkTransport = HTTPNetworkTransport(
            url: URL(string: "https://graphql.dev.hedvigit.com/graphql")!,
            client: urlSessionClient
        )

        let websocketNetworkTransport = WebSocketTransport(
            request: URLRequest(url: URL(string: "wss://graphql.dev.hedvigit.com/subscriptions")!),
            connectingPayload: httpAdditionalHeaders as GraphQLMap
        )

        let splitNetworkTransport = SplitNetworkTransport(
            httpNetworkTransport: httpNetworkTransport,
            webSocketNetworkTransport: websocketNetworkTransport
        )

        let store = ApolloStore(cache: InMemoryNormalizedCache())
        let client = ApolloClient(networkTransport: splitNetworkTransport, store: store)
        
        Dependencies.shared.add(module: Module { () -> URLSessionClient in
            urlSessionClient
        })

        Dependencies.shared.add(module: Module { () -> ApolloClient in
            client
        })

        Dependencies.shared.add(module: Module { () -> ApolloStore in
            store
        })

        return (store, client)
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let bag = DisposeBag()

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()

        _ = ApolloClient.createClient(token: nil)

        let navigationController = UINavigationController()
        window?.rootViewController = navigationController

        Bundle.setLanguage("en-SE")

        bag += navigationController.present(Embark(
            name: "Web Onboarding - Swedish Needer"
        ))

        return true
    }
}
