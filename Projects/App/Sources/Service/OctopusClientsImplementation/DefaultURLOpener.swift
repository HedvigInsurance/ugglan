import Authentication
import UIKit
import hCore

class DefaultURLOpener: URLOpener {
    @Inject private var authorizationCodeClient: AuthorizationCodeClient

    public func openWithAuthorizationCode(_ url: URL) async {
        var urlToOpen = url
        do {
            let code = try await authorizationCodeClient.getAuthorizationCode().authorizationCode
            if var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                var queryItems = components.queryItems ?? []
                queryItems.append(URLQueryItem(name: "authorization_code", value: code))
                components.queryItems = queryItems
                if let authorizedURL = components.url {
                    urlToOpen = authorizedURL
                }
            }
        } catch {
            log.error("Failed to get authorization code", error: error, attributes: nil)
        }
        await UIApplication.shared.open(urlToOpen)
    }

    public func open(_ url: URL) {
        log.info("Opening URL: \(url.absoluteString)", error: nil, attributes: nil)
        UIApplication.shared.open(url)
    }
}
