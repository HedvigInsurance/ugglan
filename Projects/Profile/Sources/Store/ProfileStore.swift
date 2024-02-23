import Apollo
import Flow
import Foundation
import Presentation
import hCore
import hGraphQL

public final class ProfileStore: LoadingStateStore<ProfileState, ProfileAction, ProfileLoadingAction> {
    @Inject var profileService: ProfileService

    public override func effects(
        _ getState: @escaping () -> ProfileState,
        _ action: ProfileAction
    ) -> FiniteSignal<ProfileAction>? {
        switch action {
        case .fetchProfileState:
            return FiniteSignal { [weak self] callback in guard let self = self else { return DisposeBag() }
                let disposeBag = DisposeBag()
                Task {
                    do {
                        let (member, partner) = try await self.profileService.getProfileState()
                        self.removeLoading(for: .fetchProfileState)
                        callback(.value(.setEurobonusNumber(partnerData: partner)))
                        callback(.value(.setMember(memberData: member)))
                        callback(.value(.setHasTravelCertificate(has: member.hasTravelCertificate)))
                        callback(.value(.fetchProfileStateCompleted))
                    } catch {
                        self.setError(error.localizedDescription, for: .fetchProfileState)
                        callback(.value(.fetchProfileStateCompleted))
                    }
                }
                return disposeBag
            }
        case .fetchMemberDetails:
            return FiniteSignal { [weak self] callback in guard let self = self else { return DisposeBag() }
                let disposeBag = DisposeBag()
                Task {
                    do {
                        let memberDetails = try await self.profileService.getMemberDetails()
                        self.removeLoading(for: .fetchMemberDetails)
                        callback(.value(.setMemberDetails(details: memberDetails)))
                    } catch {
                        self.setError(error.localizedDescription, for: .fetchMemberDetails)
                    }
                }
                return disposeBag
            }
        case .languageChanged:
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                callback(.value(.updateLanguage))
                return disposeBag
            }
        case .updateLanguage:
            return FiniteSignal { [weak self] callback in guard let self = self else { return DisposeBag() }
                let disposeBag = DisposeBag()
                Task {
                    do {
                        try await self.profileService.getProfileState()
                        self.removeLoading(for: .updateLanguage)
                    } catch {
                        self.setError(error.localizedDescription, for: .updateLanguage)
                    }
                }
                return disposeBag
            }
        default:
            return nil
        }
    }

    public override func reduce(_ state: ProfileState, _ action: ProfileAction) -> ProfileState {
        var newState = state
        switch action {
        case .fetchProfileState:
            setLoading(for: .fetchProfileState)
        case .fetchMemberDetails:
            setLoading(for: .fetchProfileState)
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
            newState.memberDetails =
                details
                ?? MemberDetails(id: "", firstName: "", lastName: "", phone: "", email: "", hasTravelCertificate: false)
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
