import Combine
import Foundation
import hCore

@MainActor
public class PaymentsDiscountsRootViewModel: ObservableObject {
    @Published public var viewState: ProcessingState = .loading
    @Published public var paymentDiscountsData: PaymentDiscountsData?

    private let campaignService = hCampaignService()

    public init() {}

    public func fetch() async {
        viewState = .loading
        do {
            let data = try await campaignService.getPaymentDiscountsData()
            paymentDiscountsData = data
            viewState = .success
        } catch {
            viewState = .error(errorMessage: L10n.General.errorBody)
        }
    }

    public func fetch() {
        Task {
            await fetch()
        }
    }
}
