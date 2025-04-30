import PresentableStore
import hGraphQL

public enum CampaignAction: ActionProtocol {
    case fetchDiscountsData
    case setDiscountsData(data: PaymentDiscountsData)
}
