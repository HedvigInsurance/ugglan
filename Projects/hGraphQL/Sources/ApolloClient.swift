@preconcurrency import Apollo
@preconcurrency import ApolloWebSocket
import Disk
import Foundation
import SwiftUI

public struct hApollo {
    public let octopus: hOctopus
}

public struct hOctopus {
    public let client: ApolloClient
    public let store: ApolloStore
}

@MainActor
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

    public static func headers() async -> [String: String] {
        if let token = try? await ApolloClient.retreiveToken() {
            return [
                "Authorization": "Bearer " + token.accessToken,
                "Accept-Language": acceptLanguageHeader,
                "User-Agent": userAgent,
            ]
        }
        return ["Accept-Language": acceptLanguageHeader, "User-Agent": userAgent]
    }

    public static func getDeviceIdentifier() async -> String {
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

    static func createOctopusClient() async -> hOctopus {
        let environment = Environment.current

        _ = await headers()

        let store = ApolloStore(cache: ApolloClient.cache)

        let networkInterceptorProvider = NetworkInterceptorProvider(
            store: store,
            acceptLanguageHeader: { acceptLanguageHeader },
            userAgent: userAgent,
            deviceIdentifier: await getDeviceIdentifier()
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

    public static func createClient() async -> hApollo {
        return hApollo(
            octopus: await createOctopusClient()
        )
    }

    public static func deleteToken() async {
        await KeychainHelper.standard.delete(key: "oAuthorizationToken")
    }

    public static func retreiveToken() async throws -> OAuthorizationToken? {
        try await KeychainHelper.standard.read(key: "oAuthorizationToken", type: OAuthorizationToken.self)
    }

    public static func handleAuthTokenSuccessResult(result: AuthorizationTokenDto) {
        let accessTokenExpirationDate = Date()
            .addingTimeInterval(
                Double(result.accessTokenExpiryIn)
            )

        let refreshTokenExpirationDate = Date()
            .addingTimeInterval(
                Double(result.refreshTokenExpiryIn)
            )

        ApolloClient.saveToken(
            token: OAuthorizationToken(
                accessToken: result.accessToken,
                accessTokenExpirationDate: accessTokenExpirationDate,
                refreshToken: result.refreshToken,
                refreshTokenExpirationDate: refreshTokenExpirationDate
            )
        )
    }

    public static func saveToken(token: OAuthorizationToken) {
        KeychainHelper.standard.save(token, key: "oAuthorizationToken")
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
