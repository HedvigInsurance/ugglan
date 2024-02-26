import Apollo
import ApolloWebSocket
import Disk
import Flow
import Foundation
import UIKit
import authlib

public struct hApollo {
    public let octopus: hOctopus
}

public struct hOctopus {
    public let client: ApolloClient
    public let store: ApolloStore
}

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

    public static func headers() -> [String: String] {
        if let token = try? ApolloClient.retreiveToken() {
            return [
                "Authorization": "Bearer " + token.accessToken,
                "Accept-Language": acceptLanguageHeader,
                "User-Agent": userAgent,
            ]
        }

        return ["Accept-Language": acceptLanguageHeader, "User-Agent": userAgent]
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

    static func createOctopusClient() -> hOctopus {
        let environment = Environment.current

        let httpAdditionalHeaders = headers()

        let store = ApolloStore(cache: ApolloClient.cache)

        let networkInterceptorProvider = NetworkInterceptorProvider(
            store: store,
            acceptLanguageHeader: acceptLanguageHeader,
            userAgent: userAgent,
            deviceIdentifier: getDeviceIdentifier()
        )

        let requestChainTransport = RequestChainNetworkTransport(
            interceptorProvider: networkInterceptorProvider,
            endpointURL: environment.octopusEndpointURL
        )

        let clientName = "iOS:\(bundle?.bundleIdentifier ?? "")"

        requestChainTransport.clientName = clientName
        requestChainTransport.clientVersion = appVersion

        let client = ApolloClient(networkTransport: requestChainTransport, store: store)

        return hOctopus(client: client, store: store)
    }

    public static func createClient() -> hApollo {
        return hApollo(
            octopus: createOctopusClient()
        )
    }

    public static func deleteToken() {
        KeychainHelper.standard.delete(key: "oAuthorizationToken")
    }

    public static func retreiveToken() throws -> OAuthorizationToken? {
        try KeychainHelper.standard.read(key: "oAuthorizationToken", type: OAuthorizationToken.self)
    }

    public static func handleAuthTokenSuccessResult(result: AuthTokenResultSuccess) {
        let accessTokenExpirationDate = Date()
            .addingTimeInterval(
                Double(result.accessToken.expiryInSeconds)
            )

        let refreshTokenExpirationDate = Date()
            .addingTimeInterval(
                Double(result.refreshToken.expiryInSeconds)
            )

        ApolloClient.saveToken(
            token: OAuthorizationToken(
                accessToken: result.accessToken.token,
                accessTokenExpirationDate: accessTokenExpirationDate,
                refreshToken: result.refreshToken.token,
                refreshTokenExpirationDate: refreshTokenExpirationDate
            )
        )
    }

    public static func saveToken(token: OAuthorizationToken) {
        KeychainHelper.standard.save(token, key: "oAuthorizationToken")
    }

    public static func initClients() -> Future<hApollo> {
        Future { completion in
            let result = self.createClient()
            completion(.success(result))
            return NilDisposer()
        }
    }

    public static func retreiveMembersWithDeleteRequests() -> Set<String> {
        let memberIds = try? Disk.retrieve("deleteRequestedMembers", from: .applicationSupport, as: Set<String>.self)
        return memberIds ?? []
    }

    public static func saveDeleteAccountStatus(for memberId: String) {
        var members = retreiveMembersWithDeleteRequests()
        members.insert(memberId)
        try? Disk.save(members, to: .applicationSupport, as: "deleteRequestedMembers")
    }

    public static func removeDeleteAccountStatus(for memberId: String) {
        var members = retreiveMembersWithDeleteRequests()
        members.remove(memberId)
        try? Disk.save(members, to: .applicationSupport, as: "deleteRequestedMembers")
    }

    public static func deleteAccountStatus(for memberId: String) -> Bool {
        let members = retreiveMembersWithDeleteRequests()
        return members.contains(memberId)
    }
}
