import PresentableStore
import hCore

public enum LoadingAction: LoadingProtocol {
    case getDiscountsData
}

public final class CampaignStore: LoadingStateStore<CampaignState, CampaignAction, LoadingAction> {
    @Inject var campaignService: hCampaignClient

    public override func effects(_ getState: @escaping () -> CampaignState, _ action: CampaignAction) async {
        switch action {
        case .fetchDiscountsData:
            do {
                let data = try await self.campaignService.getPaymentDiscountsData()
                self.send(.setDiscountsData(data: data))
            } catch {
                self.setError(L10n.General.errorBody, for: .getDiscountsData)
            }
        default:
            break
        }
    }

    public override func reduce(_ state: CampaignState, _ action: CampaignAction) async -> CampaignState {
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
