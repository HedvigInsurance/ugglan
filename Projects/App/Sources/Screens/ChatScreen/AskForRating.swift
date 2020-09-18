import Foundation
import StoreKit

struct AskForRating {
    let userDefaultsKey = "AskForRating"
    let userDefaultsCompletedKey = "AskForRatingCompleted"

    func registerSession() {
        var numberOfSessions = UserDefaults.standard.value(forKey: userDefaultsKey) as? Int ?? 0
        numberOfSessions += 1
        UserDefaults.standard.set(numberOfSessions, forKey: userDefaultsKey)
    }

    func ask() {
        guard !UserDefaults.standard.bool(forKey: userDefaultsCompletedKey) else {
            return
        }

        let numberOfSessions = UserDefaults.standard.value(forKey: "AskForRating") as? Int ?? 0

        if numberOfSessions >= 3 {
            UserDefaults.standard.set(true, forKey: userDefaultsCompletedKey)
            SKStoreReviewController.requestReview()
        }
    }
}
