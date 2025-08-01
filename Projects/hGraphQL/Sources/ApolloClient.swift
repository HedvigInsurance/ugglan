@preconcurrency import Apollo
@preconcurrency import ApolloWebSocket
import Disk
import Environment
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
public extension ApolloClient {
    static var acceptLanguageHeader: String = ""
    static var bundle: Bundle?

    internal static var appVersion: String {
        bundle?.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }

    static var userAgent: String {
        "\(bundle?.bundleIdentifier ?? "") \(appVersion) (iOS \(UIDevice.current.systemVersion))"
    }

    static var cache = InMemoryNormalizedCache()

    static func headers() async -> [String: String] {
        if let token = try? await ApolloClient.retreiveToken() {
            return [
                "Authorization": "Bearer " + token.accessToken,
                "Accept-Language": acceptLanguageHeader,
                "User-Agent": userAgent,
            ]
        }
        return ["Accept-Language": acceptLanguageHeader, "User-Agent": userAgent]
    }

    static func getDeviceIdentifier() async -> String {
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

    internal static func createOctopusClient() async -> hOctopus {
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

    static func createClient() async -> hApollo {
        hApollo(
            octopus: await createOctopusClient()
        )
    }

    static func deleteToken() async {
        await KeychainHelper.standard.delete(key: "oAuthorizationToken")
    }

    static func retreiveToken() async throws -> OAuthorizationToken? {
        try await KeychainHelper.standard.read(key: "oAuthorizationToken", type: OAuthorizationToken.self)
    }

    static func handleAuthTokenSuccessResult(result: AuthorizationTokenDto) {
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

    static func saveToken(token: OAuthorizationToken) {
        KeychainHelper.standard.save(token, key: "oAuthorizationToken")
    }

    static func retreiveMembersWithDeleteRequests() -> Set<String> {
        let memberIds = try? Disk.retrieve("deleteRequestedMembers", from: .applicationSupport, as: Set<String>.self)
        return memberIds ?? []
    }

    static func saveDeleteAccountStatus(for memberId: String) {
        var members = retreiveMembersWithDeleteRequests()
        members.insert(memberId)
        try? Disk.save(members, to: .applicationSupport, as: "deleteRequestedMembers")
    }

    static func removeDeleteAccountStatus(for memberId: String) {
        var members = retreiveMembersWithDeleteRequests()
        members.remove(memberId)
        try? Disk.save(members, to: .applicationSupport, as: "deleteRequestedMembers")
    }

    static func deleteAccountStatus(for memberId: String) -> Bool {
        let members = retreiveMembersWithDeleteRequests()
        return members.contains(memberId)
    }
}
