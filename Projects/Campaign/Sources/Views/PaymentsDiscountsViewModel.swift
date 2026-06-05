import Foundation
import SwiftUI
import hCore
import hCoreUI

@MainActor
public class PaymentsDiscountsViewModel: ObservableObject {
    @Inject private var service: hCampaignClient

    @Published public var paymentDiscountsData: PaymentDiscountsData?
    @Published public var viewState: ProcessingState = .loading

    public init() {}

    public func fetchDiscountsData() async {
        viewState = .loading
        do {
            paymentDiscountsData = try await service.getPaymentDiscountsData()
            viewState = .success
        } catch {
            viewState = .error(errorMessage: L10n.General.errorBody)
        }
    }
}
