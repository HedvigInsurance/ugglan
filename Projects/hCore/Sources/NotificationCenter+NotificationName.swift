import Foundation

extension Notification.Name {
    public static let applicationWillTerminate = Notification.Name("applicationWillTerminate")
    public static let openChat = Notification.Name("openChat")
    public static let chatClosed = Notification.Name("chatClosed")
    public static let handlePushNotification = Notification.Name("handlePushNotification")
    public static let openDeepLink = Notification.Name("openDeepLink")
    public static let registerForPushNotifications = Notification.Name("registerForPushNotifications")
    public static let addonAdded = Notification.Name("addonAdded")
    public static let openCrossSell = Notification.Name("openCrossSell")
}
