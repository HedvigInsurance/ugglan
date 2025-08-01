import Apollo
import Foundation
import hCore
import PresentableStore

public final class ProfileStore: LoadingStateStore<ProfileState, ProfileAction, ProfileLoadingAction> {
    @Inject var profileService: ProfileClient

    let memberSubscriptionPreferenceViewModel = MemberSubscriptionPreferenceViewModel()
    override public func effects(
        _: @escaping () -> ProfileState,
        _ action: ProfileAction
    ) async {
        switch action {
        case .fetchProfileState:
            do {
                let (member, partner, canCreateInsuranceEvidence, hasTravelInsurances) =
                    try await profileService
                        .getProfileState()
                removeLoading(for: .fetchProfileState)

                send(.setEurobonusNumber(partnerData: partner))
                send(.setCanCreateInsuranceEvidence(to: canCreateInsuranceEvidence))
                send(.setMember(memberData: member))
                send(.canCreateTravelCertificate(to: member.isTravelCertificateEnabled))
                send(.hasTravelCertificates(to: hasTravelInsurances))
                send(.fetchProfileStateCompleted)
            } catch {
                setError(error.localizedDescription, for: .fetchProfileState)
                send(.fetchProfileStateCompleted)
            }
        case .fetchMemberDetails:
            do {
                let memberDetails = try await profileService.getMemberDetails()
                removeLoading(for: .fetchMemberDetails)
                send(.setMemberDetails(details: memberDetails))
            } catch {
                setError(error.localizedDescription, for: .fetchMemberDetails)
            }
        case .updateLanguage:
            do {
                try await profileService.updateLanguage()
                removeLoading(for: .updateLanguage)
            } catch {
                setError(error.localizedDescription, for: .updateLanguage)
            }
        default:
            break
        }
    }

    override public func reduce(_ state: ProfileState, _ action: ProfileAction) async -> ProfileState {
        var newState = state
        switch action {
        case .fetchProfileState:
            setLoading(for: .fetchProfileState)
        case .fetchMemberDetails:
            setLoading(for: .fetchMemberDetails)
        case .updateLanguage:
            setLoading(for: .updateLanguage)
        case let .setMember(memberData):
            newState.memberDetails = memberData
        case let .setEurobonusNumber(partnerData):
            newState.partnerData = partnerData
        case let .setCanCreateInsuranceEvidence(canCreate):
            newState.canCreateInsuranceEvidence = canCreate
        case let .setMemberEmail(email):
            newState.memberDetails?.email = email
        case let .setMemberPhone(phone):
            newState.memberDetails?.phone = phone
        case let .setMemberDetails(details):
            newState.memberDetails = details
        case let .setPushNotificationStatus(status):
            newState.pushNotificationStatus = status
        case let .setPushNotificationsTo(date):
            newState.pushNotificationsSnoozeDate = date
        case let .hasTravelCertificates(hasTravelCertificates):
            newState.hasTravelCertificates = hasTravelCertificates
        case let .canCreateTravelCertificate(canCreate):
            newState.canCreateTravelInsurance = canCreate
        default:
            break
        }

        return newState
    }
}
