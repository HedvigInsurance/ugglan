import Apollo
import ApolloWebSocket
import Embark
import Flow
import Form
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

        let environment = ApolloEnvironmentConfig(
            endpointURL: URL(string: "https://graphql.dev.hedvigit.com/graphql")!,
            wsEndpointURL: URL(string: "wss://graphql.dev.hedvigit.com/subscriptions")!,
            assetsEndpointURL: URL(string: "https://graphql.dev.hedvigit.com")!
        )

        Dependencies.shared.add(module: Module { () -> ApolloEnvironmentConfig in
            environment
        })

        let httpNetworkTransport = HTTPNetworkTransport(
            url: environment.endpointURL,
            client: urlSessionClient
        )

        let websocketNetworkTransport = WebSocketTransport(
            request: URLRequest(url: environment.wsEndpointURL),
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
        navigationController.navigationBar.prefersLargeTitles = true
        window?.rootViewController = navigationController

        Bundle.setLanguage("en-SE")
        DefaultStyling.installCustom()

        bag += navigationController.present(
            StoryList(),
            options: [.defaults, .largeTitleDisplayMode(.always)]
        )

        return true
    }
}
