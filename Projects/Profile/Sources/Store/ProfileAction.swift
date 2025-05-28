import Foundation
import PresentableStore
import hCore

public indirect enum ProfileAction: ActionProtocol, Hashable {
    case fetchProfileState
    case setMember(memberData: MemberDetails)
    case setMemberEmail(email: String)
    case setMemberPhone(phone: String)
    case setEurobonusNumber(partnerData: PartnerData?)
    case setCanCreateInsuranceEvidence(to: Bool)
    case hasTravelCertificates(to: Bool)
    case canCreateTravelCertificate(to: Bool)
    case fetchProfileStateCompleted
    case setMemberDetails(details: MemberDetails)
    case fetchMemberDetails
    case setPushNotificationStatus(status: Int?)
    case setPushNotificationsTo(date: Date?)
    case updateLanguage
}

public enum ProfileLoadingAction: LoadingProtocol {
    case fetchProfileState
    case fetchMemberDetails
    case updateLanguage
}
