import Foundation
import Presentation
import hCore
import hGraphQL

public enum ProfileAction: ActionProtocol {
    case fetchProfileState
    case openProfile
    case openPayment
    case openEuroBonus
    case openTravelCertificate
    case openChangeEuroBonus
    case dismissChangeEuroBonus
    case openSuccessChangeEuroBonus
    case openFreeTextChat
    case openAppInformation
    case openAppSettings(animated: Bool)
    case setMember(id: String, name: String, email: String, phone: String?)
    case setMemberEmail(email: String)
    case setMemberPhone(phone: String)
    case setEurobonusNumber(partnerData: PartnerData?)
    case setHasTravelCertificate(has: Bool)
    case fetchProfileStateCompleted
    case updateEurobonusNumber(number: String)
    case setOpenAppSettings(to: Bool)
    case openLangaugePicker
    case closeLanguagePicker
    case languageChanged

    case setMemberDetails(details: MemberDetails?)
    case fetchMemberDetails

    case deleteAccount(details: MemberDetails)
    case deleteAccountAlreadyRequested
    case sendAccountDeleteRequest(details: MemberDetails)
    case makeTabActive(deeplink: DeepLink)

    case openChat
    case dismissScreen(openChatAfter: Bool)
    case logout

    case setPushNotificationStatus(status: Int?)
    case setPushNotificationsTo(date: Date?)

    case registerForPushNotifications
    case goToURL(url: URL)

    case updateLanguage
}

public enum ProfileLoadingAction: LoadingProtocol {
    case loading
}
