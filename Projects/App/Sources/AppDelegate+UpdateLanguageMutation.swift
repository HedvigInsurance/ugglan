import Apollo
import Flow
import Foundation
import hCore
import hGraphQL

extension AppDelegate {
    func updateLanguageMutation(numberOfRetries: Int = 0) {
        let locale = Localization.Locale.currentLocale
        let client: ApolloClient = Dependencies.shared.resolve()
        client.perform(
            mutation: GraphQL.UpdateLanguageMutation(
                language: locale.code,
                pickedLocale: locale.asGraphQLLocale()
            )
        )
        .onValue { _ in
            log.info("Updated language successfully")
        }
        .onError { error in
            log.info("Failed updating language, retries in \(numberOfRetries * 100) ms")

            Signal(after: Double(numberOfRetries) * 0.1).future
                .onValue { _ in
                    self.updateLanguageMutation(numberOfRetries: numberOfRetries + 1)
                }
        }
    }
}
