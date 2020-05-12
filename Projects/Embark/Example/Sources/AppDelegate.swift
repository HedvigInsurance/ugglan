//
//  AppDelegate.swift
//  
//
//  Created by Sam Pettersson on 2020-05-06.
//

import Foundation
import UIKit
import Presentation
import Embark
import Flow
import Apollo
import ApolloWebSocket
import hCore

extension ApolloClient {
    static func createClient(token: String?) -> (ApolloStore, ApolloClient) {
        let httpAdditionalHeaders = [
            "Authorization": "SXjDmWsfPNG4Dw==.1dCSCrv8Te5PpQ==.yHXEgngWUvfcUA==",
            "User-Agent": "iOS"
        ]

        let configuration = URLSessionConfiguration.default

        configuration.httpAdditionalHeaders = httpAdditionalHeaders

        let urlSessionClient = URLSessionClient(sessionConfiguration: configuration)
        
        let httpNetworkTransport = HTTPNetworkTransport(
            url: URL(string: "https://graphql.dev.hedvigit.com/graphql")!,
            client: urlSessionClient
        )

        let websocketNetworkTransport = WebSocketTransport(
            request: URLRequest(url:  URL(string: "wss://graphql.dev.hedvigit.com/subscriptions")!),
            connectingPayload: httpAdditionalHeaders as GraphQLMap
        )

        let splitNetworkTransport = SplitNetworkTransport(
            httpNetworkTransport: httpNetworkTransport,
            webSocketNetworkTransport: websocketNetworkTransport
        )

        let store = ApolloStore(cache: InMemoryNormalizedCache())
        let client = ApolloClient(networkTransport: splitNetworkTransport, store: store)

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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        
        let _ = ApolloClient.createClient(token: nil)
        
        let navigationController = UINavigationController()
        self.window?.rootViewController = navigationController
        
        bag += navigationController.present(Embark(
            name: "Web Onboarding - English Needer"
        ))
        
        return true
    }

}
