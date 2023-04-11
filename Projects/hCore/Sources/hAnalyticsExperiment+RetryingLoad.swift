import Foundation
import hAnalytics
import hGraphQL

extension hAnalyticsExperiment {
    private static func retryingLoad(numberOfTries: Int, onComplete: @escaping (_ success: Bool) -> Void) {
        log.info("Started loading hAnlyticsExperiments")
        hAnalyticsExperiment.load { success in
            if success {
                log.info("Successfully loaded hAnlyticsExperiments")
                onComplete(true)
            } else if numberOfTries > 20 {
                log.info("Failed to load hAnlyticsExperiments after 20 tries")
                onComplete(false)
            } else {
                log.info("Failed loading hAnlyticsExperiments, retries in \(numberOfTries * 100) ms")
                DispatchQueue.main.asyncAfter(deadline: .now() + (Double(numberOfTries) * 0.1)) {
                    self.retryingLoad(numberOfTries: numberOfTries + 1, onComplete: onComplete)
                }
            }
        }
    }
    
    public static func retryingLoad(onComplete: @escaping (_ success: Bool) -> Void) {
        log.info("Started loading hAnlyticsExperiments")
        self.retryingLoad(numberOfTries: 0, onComplete: onComplete)
    }
}
