import Apollo
import Flow
import Foundation
import Presentation
import hCore
import hGraphQL

public final class ProfileStore: StateStore<ProfileState, ProfileAction> {
    @Inject var octopus: hOctopus

    public override func effects(
        _ getState: @escaping () -> ProfileState,
        _ action: ProfileAction
    ) -> FiniteSignal<ProfileAction>? {
        switch action {
        case .fetchProfileState:
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                let getProfileData = self.octopus.client
                    .fetch(
                        query: OctopusGraphQL.ProfileQuery(),
                        cachePolicy: .fetchIgnoringCacheData
                    )
                disposeBag +=
                    getProfileData.onValue({ profileData in
                        let name = profileData.currentMember.firstName + " " + profileData.currentMember.lastName
                        let partner = PartnerData(with: profileData.currentMember.fragments.partnerDataFragment)
                        callback(.value(.setEurobonusNumber(partnerData: partner)))
                        callback(
                            .value(
                                .setMember(
                                    id: profileData.currentMember.id,
                                    name: name,
                                    email: profileData.currentMember.email,
                                    phone: profileData.currentMember.phoneNumber
                                )
                            )
                        )
                        callback(.value(.fetchProfileStateCompleted))
                    })
                    .onError({ error in
                        //TODO: HANDLE ERROR
                        callback(.value(.fetchProfileStateCompleted))
                    })

                return disposeBag
            }
        case .fetchMemberDetails:
            let query = OctopusGraphQL.MemberDetailsQuery()
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag += self.octopus.client
                    .fetch(
                        query: query,
                        cachePolicy: .returnCacheDataElseFetch
                    )
                    .compactMap { details in
                        let details = MemberDetails(memberData: details.currentMember)
                        callback(.value(.setMemberDetails(details: details)))
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
            let locale = Localization.Locale.currentLocale
            let mutation = OctopusGraphQL.MemberUpdateLanguageMutation(input: .init(ietfLanguageTag: locale.lprojCode))
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                disposeBag += self.octopus.client
                    .perform(
                        mutation: mutation
                    )
                    .onValue { _ in }
                    .onError { error in
                        log.warn("Failed updating language", error: error)
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
        case let .setMember(id, name, email, phone):
            newState.memberId = id
            newState.memberFullName = name
            newState.memberPhone = phone
            newState.memberEmail = email
        case .setEurobonusNumber(let partnerData):
            newState.partnerData = partnerData
        case let .setMemberEmail(email):
            newState.memberEmail = email
        case let .setMemberPhone(phone):
            newState.memberPhone = phone
        case let .setOpenAppSettings(to):
            newState.openSettingsDirectly = to
        case let .setMemberDetails(details):
            newState.memberDetails = details ?? MemberDetails(id: "", firstName: "", lastName: "", phone: "", email: "")
        case let .setPushNotificationStatus(status):
            newState.pushNotificationStatus = status
        case let .setPushNotificationsTo(date):
            newState.pushNotificationsSnoozeDate = date
        default:
            break
        }

        return newState
    }
}
