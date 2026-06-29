import AuthenticationCore
import AutomaticLog
import UIKit
import hCore

class DefaultURLOpener: URLOpener {
    @Inject private var authorizationCodeClient: AuthorizationCodeClient

    @Log
    public func open(_ url: URL) async {
        let urlToOpen = url.requiresAuthorization ? await urlWithAuthorizationCode(url) : url
        await UIApplication.shared.open(urlToOpen)
    }

    private func urlWithAuthorizationCode(_ url: URL) async -> URL {
        do {
            let code = try await authorizationCodeClient.getAuthorizationCode().authorizationCode
            if var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                var queryItems = components.queryItems ?? []
                queryItems.append(URLQueryItem(name: "authorization_code", value: code))
                components.queryItems = queryItems
                if let authorizedURL = components.url {
                    return authorizedURL
                }
            }
        } catch {
            log.error("Failed to get authorization code", error: error, attributes: nil)
        }
        return url
    }
}
