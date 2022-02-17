import Apollo
import Foundation
import hGraphQL
import Flow
import hCore
import hGraphQL
import SwiftUI

struct Impersonate {
    @Inject var client: ApolloClient
    
    private func getToken(from url: URL) -> String? {
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let items = (urlComponents?.queryItems)! as [NSURLQueryItem]
        if (url.scheme == "hedvigengineering"),
           let token = items.first,
           token.name == "token",
           let value = token.value,
           let exchangeToken = value.split(separator: "=").last {
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
        
        client.perform(
            mutation: GraphQL.ExchangeTokenMutation(
                exchangeToken: exchangeToken.removingPercentEncoding ?? ""
            )
        )
        .onValue { response in
            guard
                let token = response.exchangeToken
                    .asExchangeTokenSuccessResponse?
                    .token
            else { return }
            
            ApolloClient.cache = InMemoryNormalizedCache()
            ApolloClient.saveToken(token: token)
            ApolloClient.initAndRegisterClient()
                .always {
                    ChatState.shared = ChatState()
                    UIApplication.shared.appDelegate.bag +=
                        UIApplication.shared.appDelegate
                        .window.present(AppJourney.loggedIn)
                }
        }
    }
}

