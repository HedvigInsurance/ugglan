import Apollo
import Flow
import Foundation
import Presentation
import hCore

public final class ProfileStore: LoadingStateStore<ProfileState, ProfileAction, ProfileLoadingAction> {
    @Inject var profileService: ProfileService

    public override func effects(
        _ getState: @escaping () -> ProfileState,
        _ action: ProfileAction
    ) async throws {
        switch action {
        case .fetchProfileState:
            do {
                let (member, partner) = try await self.profileService.getProfileState()
                self.removeLoading(for: .fetchProfileState)

                send(.setEurobonusNumber(partnerData: partner))
                send(.setMember(memberData: member))
                send(.setHasTravelCertificate(has: member.hasTravelCertificate))
                send(.fetchProfileStateCompleted)
            } catch let error {
                self.setError(error.localizedDescription, for: .fetchProfileState)
                send(.fetchProfileStateCompleted)
            }
        case .fetchMemberDetails:
            do {
                let memberDetails = try await self.profileService.getMemberDetails()
                self.removeLoading(for: .fetchMemberDetails)
                send(.setMemberDetails(details: memberDetails))
            } catch let error {
                self.setError(error.localizedDescription, for: .fetchMemberDetails)
            }
        case .languageChanged:
            send(.updateLanguage)
        case .updateLanguage:
            do {
                try await self.profileService.updateLanguage()
                self.removeLoading(for: .updateLanguage)
            } catch let error {
                self.setError(error.localizedDescription, for: .updateLanguage)
            }
        default:
            break
        }
    }

    public override func reduce(_ state: ProfileState, _ action: ProfileAction) -> ProfileState {
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
        case .setEurobonusNumber(let partnerData):
            newState.partnerData = partnerData
        case let .setMemberEmail(email):
            newState.memberDetails?.email = email
        case let .setMemberPhone(phone):
            newState.memberDetails?.phone = phone
        case let .setOpenAppSettings(to):
            newState.openSettingsDirectly = to
        case let .setMemberDetails(details):
            newState.memberDetails = details
        case let .setPushNotificationStatus(status):
            newState.pushNotificationStatus = status
        case let .setPushNotificationsTo(date):
            newState.pushNotificationsSnoozeDate = date
        case let .setHasTravelCertificate(hasTravelCertificates):
            newState.hasTravelCertificates = hasTravelCertificates
        default:
            break
        }

        return newState
    }
}
