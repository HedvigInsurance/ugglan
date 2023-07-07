import Apollo
import Flow
import Presentation
import hCore
import hCoreUI
import hGraphQL

public struct ProfileState: StateProtocol {
    var memberFullName: String = ""
    var memberEmail: String = ""
    var monthlyNet: Int = 0
    var partnerData: PartnerData?
    @OptionalTransient var updateEurobonusState: LoadingState<String>?
    public init() {}
}

public enum LoadingState<T>: Codable & Equatable & Hashable where T: Codable & Equatable & Hashable {
    case loading
    case error(error: T)
}

public enum ProfileAction: ActionProtocol {
    case fetchProfileState
    case openProfile
    case openCharity
    case openPayment
    case openEuroBonus
    case openFreeTextChat
    case openAppInformation
    case openAppSettings
    case setProfileState(name: String, email: String, monthlyNet: Int)
    case setEurobonusNumber(partnerData: PartnerData?)
    case fetchProfileStateCompleted
    case updateEurobonusNumber(number: String)
    case updateEurobonusState(with: LoadingState<String>?)
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

                let getProfileData = self.giraffe.client
                    .fetch(
                        query: GiraffeGraphQL.ChargeEstimationQuery(),
                        cachePolicy: .fetchIgnoringCacheData
                    )

                let getPartnerData = self.octopus.client
                    .fetch(
                        query: OctopusGraphQL.ProfileQuery(),
                        cachePolicy: .fetchIgnoringCacheData
                    )
                disposeBag += combineLatest(getProfileData.resultSignal, getPartnerData.resultSignal)
                    .onValue { (profileData, partnerData) in
                        var monthlyNet = 0
                        if let profileData = profileData.value {
                            monthlyNet = Int(
                                profileData.chargeEstimation.subscription.fragments.monetaryAmountFragment
                                    .monetaryAmount.floatAmount
                            )
                        }
                        if let partnerData = partnerData.value {
                            let name = partnerData.currentMember.firstName + " " + partnerData.currentMember.lastName
                            let email = partnerData.currentMember.email
                            let partner = PartnerData(with: partnerData.currentMember.fragments.partnerDataFragment)
                            callback(.value(.setEurobonusNumber(partnerData: partner)))
                            callback(.value(.setProfileState(name: name, email: email, monthlyNet: monthlyNet)))
                        }
                        callback(.value(.fetchProfileStateCompleted))
                    }

                return disposeBag
            }
        case let .updateEurobonusNumber(number):
            return FiniteSignal { callback in
                let disposeBag = DisposeBag()
                let input = OctopusGraphQL.MemberUpdateEurobonusNumberInput(eurobonusNumber: number)
                disposeBag += self.octopus.client
                    .perform(mutation: OctopusGraphQL.UpdateEurobonusNumberMutation(input: input))
                    .onValue { result in
                        if let error = result.memberUpdateEurobonusNumber.userError?.message, error != "" {
                            callback(.value(.updateEurobonusState(with: .error(error: error))))
                        } else if let partnerData = result.memberUpdateEurobonusNumber.member?.fragments
                            .partnerDataFragment
                        {
                            callback(.value(.setEurobonusNumber(partnerData: PartnerData(with: partnerData))))
                            callback(.value(.updateEurobonusState(with: nil)))
                        } else {
                            callback(
                                .value(.updateEurobonusState(with: .error(error: L10n.SasIntegration.incorrectNumber)))
                            )
                        }
                    }
                    .onError { _ in
                        callback(.value(.updateEurobonusState(with: .error(error: L10n.General.errorBody))))
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
        case .setProfileState(let name, let email, let monthlyNet):
            newState.memberFullName = name
            newState.memberEmail = email
            newState.monthlyNet = monthlyNet
        case .setEurobonusNumber(let partnerData):
            newState.partnerData = partnerData
        case .updateEurobonusNumber:
            newState.updateEurobonusState = .loading
        case let .updateEurobonusState(state):
            newState.updateEurobonusState = state
            if state == nil {
                Toasts.shared.displayToast(
                    toast: Toast(
                        symbol: .icon(hCoreUIAssets.editIcon.image),
                        body: L10n.profileMyInfoSaveSuccessToastBody
                    )
                )
            }
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
