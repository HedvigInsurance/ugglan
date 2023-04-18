import Apollo
import Flow
import Presentation
import hCore
import hGraphQL

public struct ProfileState: StateProtocol {
    var memberFullName: String = ""
    var memberCharityName: String = ""
    var monthlyNet: Int = 0
    public init() {}
}

public enum ProfileAction: ActionProtocol {
    case fetchProfileState
    case openProfile
    case openCharity
    case openPayment
    case openFreeTextChat
    case openAppInformation
    case openAppSettings
    case setProfileState(name: String, charity: String, monthlyNet: Int)
}

public final class ProfileStore: StateStore<ProfileState, ProfileAction> {
    @Inject var giraffe: hGiraffe

    public override func effects(
        _ getState: @escaping () -> ProfileState,
        _ action: ProfileAction
    ) -> FiniteSignal<ProfileAction>? {
        switch action {
        case .fetchProfileState:
            return
                giraffe
                .client
                .fetch(query: GiraffeGraphQL.ProfileQuery(), cachePolicy: .fetchIgnoringCacheData)
                .map { data in
                    let name = (data.member.firstName ?? "") + " " + (data.member.lastName ?? "")
                    let charity = data.cashback?.name ?? ""
                    //                    let monthlyNet = Int(Float(data.insuranceCost?.fragments.costFragment.monthlyNet.amount ?? "") ?? 0)
                    /* TODO: FIX */
                    let monthlyNet = Int(data.chargeEstimation.subscription.fragments.monetaryAmountFragment.amount)
                    return .setProfileState(name: name, charity: charity, monthlyNet: monthlyNet ?? 0)
                }
                .valueThenEndSignal
        default:
            return nil
        }
    }

    public override func reduce(_ state: ProfileState, _ action: ProfileAction) -> ProfileState {
        var newState = state
        switch action {
        case .setProfileState(let name, let charity, let monthlyNet):
            newState.memberFullName = name
            newState.memberCharityName = charity
            newState.monthlyNet = monthlyNet
        default:
            break
        }

        return newState
    }
}
