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
        let hOctopus: hOctopus = Dependencies.shared.resolve()
        let mutation = OctopusGraphQL.MemberUpdateLanguageMutation(input: .init(ietfLanguageTag: locale.lprojCode))
        hOctopus.client
            .perform(
                mutation: mutation
            )
            .onValue { data in
                if let error = data.memberUpdateLanguage.userError {
                    log.info("Failed updating language \(error.message ?? ""), retries in \(numberOfRetries * 100) ms")

                    Signal(after: Double(numberOfRetries) * 0.1).future
                        .onValue { _ in
                            self.updateLanguageMutation(numberOfRetries: numberOfRetries + 1)
                        }
                } else {
                    log.info("Updated language successfully")
                }
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
