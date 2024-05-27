import Foundation

extension Notification.Name {
    public static let applicationWillTerminate = Notification.Name("applicationWillTerminate")
    public static let openChat = Notification.Name("openChat")
    public static let handlePushNotification = Notification.Name("handlePushNotification")
    public static let openDeepLink = Notification.Name("openDeepLink")
    public static let registerForPushNotifications = Notification.Name("registerForPushNotifications")
}
