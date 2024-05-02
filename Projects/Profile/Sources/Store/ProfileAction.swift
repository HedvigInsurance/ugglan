import Foundation
import Presentation
import hCore
import hGraphQL

public indirect enum ProfileAction: ActionProtocol, Hashable {
    case fetchProfileState
    case setMember(memberData: MemberDetails)
    case setMemberEmail(email: String)
    case setMemberPhone(phone: String)
    case setEurobonusNumber(partnerData: PartnerData?)
    case isTravelCertificateEnabled(has: Bool)
    case fetchProfileStateCompleted
    case updateEurobonusNumber(number: String)
    case setOpenAppSettings(to: Bool)
    case languageChanged

    case setMemberDetails(details: MemberDetails)
    case fetchMemberDetails

    case sendAccountDeleteRequest(details: MemberDetails)
    case logout

    case setPushNotificationStatus(status: Int?)
    case setPushNotificationsTo(date: Date?)

    case registerForPushNotifications
    case goToURL(url: URL)

    case updateLanguage
}

public enum ProfileLoadingAction: LoadingProtocol {
    case fetchProfileState
    case fetchMemberDetails
    case updateLanguage
}
