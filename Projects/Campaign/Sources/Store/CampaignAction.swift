import PresentableStore

public enum CampaignAction: ActionProtocol {
    case fetchDiscountsData
    case setDiscountsData(data: PaymentDiscountsData)
}
