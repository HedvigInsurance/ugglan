import Apollo
import Authentication
import Foundation
import SwiftUI
import hCore

@MainActor
struct Impersonate {
    var authenticationService = AuthenticationService()

    private func getAuthorizationCode(from url: URL) -> String? {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        guard let queryItems = urlComponents.queryItems else { return nil }
        let items = queryItems as [NSURLQueryItem]
        if url.scheme == "hedvigengineering",
            let queryItem = items.first,
            queryItem.name == "authorizationCode",
            let authorizationCode = queryItem.value
        {
            return String(authorizationCode)
        }
        return nil
    }

    func canImpersonate(with url: URL) -> Bool {
        if getAuthorizationCode(from: url) != nil { return true }
        return false
    }

    func impersonate(with url: URL) async {
        guard let authorizationCode = getAuthorizationCode(from: url) else { return }
        do {
            try await authenticationService.exchange(code: authorizationCode)
            ApplicationState.preserveState(.impersonation)
        } catch _ {}
    }
}
