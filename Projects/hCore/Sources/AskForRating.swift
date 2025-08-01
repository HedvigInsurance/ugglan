import Foundation
import StoreKit

public struct AskForRating {
    let userDefaultsKey = "AskForRating"
    let userDefaultsCompletedKey = "AskForRatingCompleted"
    public init() {}
    public func registerSession() {
        var numberOfSessions = UserDefaults.standard.value(forKey: userDefaultsKey) as? Int ?? 0
        numberOfSessions += 1
        UserDefaults.standard.set(numberOfSessions, forKey: userDefaultsKey)
    }

    public func askAccordingToTheNumberOfSessions() {
        guard !UserDefaults.standard.bool(forKey: userDefaultsCompletedKey) else { return }

        let numberOfSessions = UserDefaults.standard.value(forKey: "AskForRating") as? Int ?? 0

        if numberOfSessions >= 3 {
            askForReview()
        }
    }

    public func askForReview() {
        guard !UserDefaults.standard.bool(forKey: userDefaultsCompletedKey) else { return }
        UserDefaults.standard.set(true, forKey: userDefaultsCompletedKey)
        DispatchQueue.main.async {
            if let scene = UIApplication.shared.currentScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
}

extension UIApplication {
    var currentScene: UIWindowScene? {
        connectedScenes
            .first { $0.activationState == .foregroundActive } as? UIWindowScene
    }
}
