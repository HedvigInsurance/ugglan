import Apollo
import Authentication
import Flow
import Foundation
import Presentation
import hCore
import hGraphQL

extension AppDelegate {
    func performUpdateLanguage() {
        DispatchQueue.main.async {
            if let _ = ApolloClient.retreiveToken() {
                self.updateLanguageMutation()
            } else {
                let authenticationStore: AuthenticationStore = globalPresentableStoreContainer.get()

                self.bag += authenticationStore.onAction(.navigationAction(action: .authSuccess)) {
                    self.updateLanguageMutation()
                }
            }
        }
    }

    func updateLanguageMutation(numberOfRetries: Int = 0) {
        let locale = Localization.Locale.currentLocale
        let giraffe: hGiraffe = Dependencies.shared.resolve()
        giraffe.client.perform(
            mutation: GiraffeGraphQL.UpdateLanguageMutation(
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
