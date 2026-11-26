import Foundation

extension Notification.Name {
    public static let applicationWillTerminate = Notification.Name("applicationWillTerminate")
    public static let openChat = Notification.Name("openChat")
    public static let chatClosed = Notification.Name("chatClosed")
    public static let handlePushNotification = Notification.Name("handlePushNotification")
    public static let openDeepLink = Notification.Name("openDeepLink")
    public static let registerForPushNotifications = Notification.Name("registerForPushNotifications")
    public static let addonsChanged = Notification.Name("addonsChanged")
    public static let openCrossSell = Notification.Name("openCrossSell")
    public static let openChangeTier = Notification.Name("openChangeTier")
    public static let openReviewContactInfo = Notification.Name("openReviewContactInfo")
    /// Opens contact info editing with only the email field.
    public static let openEditEmail = Notification.Name("openEditEmail")
    /// Posted after the member's email was changed; `object` is the new email as a `String`.
    public static let memberEmailUpdated = Notification.Name("memberEmailUpdated")
    public static let claimCreated = Notification.Name("claimCreated")
    public static let tierChanged = Notification.Name("tierChanged")
    public static let petChipIdAdded = Notification.Name("petChipIdAdded")
    public static let openMissingPetChipId = Notification.Name("openMissingPetChipId")
    public static let didChargeOutstandingPayment = Notification.Name("didChargeOutstandingPayment")
    public static let startClaim = Notification.Name("startClaim")
    public static let openAnalyticsConsent = Notification.Name("openAnalyticsConsent")
}

public enum StartClaimInputType: Equatable {
    case regular(hasInProgress: Bool)
    case inProgress
}
