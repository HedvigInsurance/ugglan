import Apollo
import ApolloWebSocket
import Disk
import Flow
import Foundation
import UIKit

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
            let newIdentifier = UUID().uuidString

            userDefaults.set(newIdentifier, forKey: deviceKey)

            return newIdentifier
        }
    }

    internal static func createClient(token: String?) -> (ApolloStore, ApolloClient) {
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
        let query = [
            kSecAttrService: "apollo-token",
            kSecAttrAccount: "hedvig",
            kSecClass: kSecClassGenericPassword,
        ] as CFDictionary
        SecItemDelete(query)
    }

    public static func retreiveToken() -> AuthorizationToken? {
        let query = [
            kSecAttrService: "apollo-token",
            kSecAttrAccount: "hedvig",
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        var token: AuthorizationToken?
        if let data = result as? Data {
            token = try? JSONDecoder().decode(AuthorizationToken.self, from: data)
        }
        return token
    }

    public static func saveToken(token: String) {
        let authorizationToken = AuthorizationToken(token: token)
//        KeychainHelper.standard.save(authorizationToken, key: "authorization-token.json")
        do {
            let data = try JSONEncoder().encode(authorizationToken)
            let query = [
                kSecValueData: data,
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: "apollo-token",
                kSecAttrAccount: "hedvig",
            ] as CFDictionary
            
            let status = SecItemAdd(query, nil)
            
            switch status {
            case errSecSuccess:
                break
            case errSecDuplicateItem:
                // Item already exist, thus update it.
                let query = [
                    kSecAttrService: "apollo-token",
                    kSecAttrAccount: "hedvig",
                    kSecClass: kSecClassGenericPassword,
                ] as CFDictionary

                let attributesToUpdate = [kSecValueData: data] as CFDictionary
                SecItemUpdate(query, attributesToUpdate)
            default:
                print("Failed to save token: \(status)")
            }
        } catch {
            print("Fail to encode item for keychain: \(error)")
        }
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
        Future { completion in let tokenData = self.retreiveToken()

            if tokenData == nil {
                return self.createClientFromNewSession()
                    .onResult { result in
                        switch result {
                        case let .success(result): completion(.success(result))
                        case let .failure(error): completion(.failure(error))
                        }
                    }
                    .disposable
            } else {
                let result = self.createClient(token: tokenData!.token)
                completion(.success(result))
            }

            return NilDisposer()
        }
    }
}
