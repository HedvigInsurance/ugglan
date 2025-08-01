import PresentableStore
import hCore

public enum LoadingAction: LoadingProtocol {
    case getDiscountsData
}

public final class CampaignStore: LoadingStateStore<CampaignState, CampaignAction, LoadingAction> {
    @Inject var campaignService: hCampaignClient

    override public func effects(_: @escaping () -> CampaignState, _ action: CampaignAction) async {
        switch action {
        case .fetchDiscountsData:
            do {
                let data = try await campaignService.getPaymentDiscountsData()
                send(.setDiscountsData(data: data))
            } catch {
                setError(L10n.General.errorBody, for: .getDiscountsData)
            }
        default:
            break
        }
    }

    override public func reduce(_ state: CampaignState, _ action: CampaignAction) async -> CampaignState {
        var newState = state

        switch action {
        case .fetchDiscountsData:
            setLoading(for: .getDiscountsData)
        case let .setDiscountsData(data):
            removeLoading(for: .getDiscountsData)
            newState.paymentDiscountsData = data
        }
        return newState
    }
}
