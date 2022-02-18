import Apollo
import Flow
import Foundation
import SwiftUI
import hCore
import hGraphQL

struct Impersonate {
    @Inject var client: ApolloClient
    @PresentableStore var store: UgglanStore

    private func getToken(from url: URL) -> String? {
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let items = (urlComponents?.queryItems)! as [NSURLQueryItem]
        if url.scheme == "hedvigengineering",
            let token = items.first,
            token.name == "token",
            let value = token.value,
            let exchangeToken = value.split(separator: "=").last
        {
            return String(exchangeToken)
        }
        return nil
    }

    func canImpersonate(with url: URL) -> Bool {
        if getToken(from: url) != nil { return true }
        return false
    }

    func impersonate(with url: URL) {
        guard let exchangeToken = getToken(from: url) else { return }

        store.send(.exchangePaymentToken(token: exchangeToken))
    }
}
