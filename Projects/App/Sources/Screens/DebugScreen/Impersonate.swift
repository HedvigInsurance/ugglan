import Apollo
import Authentication
import Flow
import Foundation
import SwiftUI
import hCore
import hGraphQL

struct Impersonate {
    @PresentableStore var authenticationStore: AuthenticationStore
    @Inject var authentificationService: AuthentificationService
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

    func impersonate(with url: URL) {
        guard let authorizationCode = getAuthorizationCode(from: url) else { return }
        Task {
            do {
                try await authentificationService.exchange(code: authorizationCode)
                authenticationStore.send(.navigationAction(action: .impersonation))
                await UIApplication.shared.appDelegate.presentMainJourney()
            } catch let ex {

            }
        }
    }
}
