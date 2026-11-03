import Foundation
import Home
import hCore
import hGraphQL

class YearInReviewClientOctopus: YearInReviewClient {
    @Inject private var octopus: hOctopus

    func getStories() async throws -> [Story] {
        // TODO: Fetch the stories once Octopus exposes them; there is no year in review query in the schema yet.
        // Until then YearInReviewClientDemo is registered for every environment in AppDelegate+DI.
        throw YearInReviewError.notAvailable
    }
}

enum YearInReviewError: LocalizedError {
    case notAvailable

    var errorDescription: String? {
        L10n.General.errorBody
    }
}
