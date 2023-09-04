import Apollo
import Flow
import Presentation
import hCore
import hCoreUI
import hGraphQL

public struct ProfileState: StateProtocol {
    var memberId: String = ""
    var memberFullName: String = ""
    var memberEmail: String = ""
    var memberPhone: String?
    var partnerData: PartnerData?
    var openSettingsDirectly = true
    public init() {}
}

public enum ProfileAction: ActionProtocol {
    case fetchProfileState
    case openProfile
    case openCharity
    case openPayment
    case openEuroBonus
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
    case fetchProfileStateCompleted
    case updateEurobonusNumber(number: String)
    case setOpenAppSettings(to: Bool)
}

public final class ProfileStore: StateStore<ProfileState, ProfileAction> {
    @Inject var giraffe: hGiraffe
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
        default:
            break
        }

        return newState
    }
}

public struct PartnerData: Codable, Equatable {
    let sas: PartnerDataSas?

    var shouldShowEuroBonus: Bool {
        return sas?.eligible ?? false
    }

    var isConnected: Bool {
        return !(sas?.eurobonusNumber ?? "").isEmpty
    }
    init?(with data: OctopusGraphQL.PartnerDataFragment) {
        guard let sasData = data.partnerData?.sas else { return nil }
        self.sas = PartnerDataSas(with: sasData)
    }
}

public struct PartnerDataSas: Codable, Equatable {
    let eligible: Bool
    let eurobonusNumber: String?

    init(with data: OctopusGraphQL.PartnerDataFragment.PartnerDatum.Sa) {
        self.eligible = data.eligible
        self.eurobonusNumber = data.eurobonusNumber
    }
}
