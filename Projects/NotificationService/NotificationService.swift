import UserNotifications
import hGraphQL

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    //    let defaults = UserDefaults(suiteName: "group.\(Bundle.main.bundleIdentifier!)")

    let defaults = UserDefaults(suiteName: "group.com.hedvig.test.app")

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        var count: Int = (defaults?.value(forKey: "count") as? Int) ?? 0
        if let bestAttemptContent = bestAttemptContent {
            bestAttemptContent.title = "\(bestAttemptContent.title) "
            bestAttemptContent.body = "\(bestAttemptContent.body) "
            bestAttemptContent.badge = count as NSNumber
            count = count + 1
            defaults?.set(count, forKey: "count")
            contentHandler(bestAttemptContent)
        }
    }

    override func serviceExtensionTimeWillExpire() {

        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
