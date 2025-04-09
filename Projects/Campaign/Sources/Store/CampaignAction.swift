import PresentableStore

public enum CampaignAction: ActionProtocol {
    case fetchDiscountsData(paymentDataDiscounts: [Discount])
    case setDiscountsData(data: PaymentDiscountsData)
}
