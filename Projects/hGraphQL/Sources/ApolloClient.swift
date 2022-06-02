import Apollo
import ApolloWebSocket
import Disk
import Flow
import Foundation
import UIKit
import hAnalytics

extension ApolloClient {
    public static var acceptLanguageHeader: String = ""
    public static var bundle: Bundle?

    internal static var appVersion: String {
        bundle?.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }

    public static var userAgent: String {
        "\(bundle?.bundleIdentifier ?? "") \(appVersion) (iOS \(UIDevice.current.systemVersion))"
    }

    public static var cache = InMemoryNormalizedCache()

    public static func headers(token: String?) -> [String: String] {
        ["Authorization": token ?? "", "Accept-Language": acceptLanguageHeader, "User-Agent": userAgent]
    }

    public static func getDeviceIdentifier() -> String {
        let userDefaults = UserDefaults.standard

        let deviceKey = "hedvig-device-identifier"

        if let identifier = userDefaults.value(forKey: deviceKey) as? String {
            return identifier
        } else {
            let identifierForVendor = UIDevice.current.identifierForVendor ?? UUID()

            userDefaults.set(identifierForVendor.uuidString, forKey: deviceKey)

            return identifierForVendor.uuidString
        }
    }

    public static func createClient(token: String?) -> (ApolloStore, ApolloClient) {
        let environment = Environment.current

        let httpAdditionalHeaders = headers(token: token)

        let store = ApolloStore(cache: ApolloClient.cache)

        let networkInterceptorProvider = NetworkInterceptorProvider(
            store: store,
            token: token ?? "",
            acceptLanguageHeader: acceptLanguageHeader,
            userAgent: userAgent,
            deviceIdentifier: getDeviceIdentifier()
        )

        let requestChainTransport = RequestChainNetworkTransport(
            interceptorProvider: networkInterceptorProvider,
            endpointURL: environment.endpointURL
        )

        let clientName = "iOS:\(bundle?.bundleIdentifier ?? "")"

        requestChainTransport.clientName = clientName
        requestChainTransport.clientVersion = appVersion

        let websocketNetworkTransport = WebSocketTransport(
            websocket: WebSocket(request: URLRequest(url: environment.wsEndpointURL), protocol: .graphql_ws),
            clientName: clientName,
            clientVersion: appVersion,
            connectingPayload: httpAdditionalHeaders as GraphQLMap
        )

        let splitNetworkTransport = SplitNetworkTransport(
            uploadingNetworkTransport: requestChainTransport,
            webSocketNetworkTransport: websocketNetworkTransport
        )

        let client = ApolloClient(networkTransport: splitNetworkTransport, store: store)

        return (store, client)
    }

    public static func deleteToken() {
        KeychainHelper.standard.delete(key: "authorizationToken")
    }

    public static func retreiveToken() -> AuthorizationToken? {
        KeychainHelper.standard.read(key: "authorizationToken", type: AuthorizationToken.self)
    }

    public static func saveToken(token: String) {
        let authorizationToken = AuthorizationToken(token: token)
        KeychainHelper.standard.save(authorizationToken, key: "authorizationToken")
    }

    public static func createClientFromNewSession() -> Future<(ApolloStore, ApolloClient)> {
        let campaign = GraphQL.CampaignInput(source: nil, medium: nil, term: nil, content: nil, name: nil)
        let mutation = GraphQL.CreateSessionMutation(campaign: campaign, trackingId: nil)

        return Future { completion in let (_, client) = self.createClient(token: nil)

            client.perform(mutation: mutation) { result in
                switch result {
                case let .success(result):
                    guard let data = result.data else { return }

                    self.saveToken(token: data.createSession)

                    let result = self.createClient(token: data.createSession)

                    completion(.success(result))
                case let .failure(error): completion(.failure(error))
                }
            }

            return Disposer { _ = client }
        }
    }

    public static func initClient() -> Future<(ApolloStore, ApolloClient)> {
        Future { completion in
            guard let keychainToken = self.retreiveToken() else {
                // If Keychain has no entry, check back on disk and migrate that data to Keychain
                // This is due to the fact that existing installs might rely on disk for tokens
                guard
                    let diskToken = try? Disk.retrieve(
                        "authorization-token.json",
                        from: .applicationSupport,
                        as: AuthorizationToken.self
                    )
                else {
                    // If disk also has no entry, then it's a new install on this device
                    return self.createClientFromNewSession()
                        .onResult { result in
                            switch result {
                            case let .success(result): completion(.success(result))
                            case let .failure(error): completion(.failure(error))
                            }
                        }
                        .disposable
                }

                saveToken(token: diskToken.token)
                try? Disk.remove("authorization-token.json", from: .applicationSupport)
                let result = self.createClient(token: diskToken.token)
                completion(.success(result))
                return NilDisposer()
            }

            let result = self.createClient(token: keychainToken.token)
            completion(.success(result))
            return NilDisposer()
        }
    }
}
