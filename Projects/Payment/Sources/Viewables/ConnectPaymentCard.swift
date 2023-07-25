import Foundation
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct ConnectPaymentCardView: View {
    @PresentableStore var store: PaymentStore

    public init() {}

    public var body: some View {
        VStack {
            PresentableStoreLens(
                PaymentStore.self,
                getter: { state in
                    state.paymentStatusData
                }
            ) { paymentStatusData in
                if paymentStatusData?.status == .needsSetup {
                    InfoCard(text: L10n.InfoCardMissingPayment.body, type: .attention)
                        .buttons([
                            .init(
                                buttonTitle: L10n.PayInExplainer.buttonText,
                                buttonAction: {
                                    store.send(.connectPayments)
                                }
                            )
                        ])
                } else if let failedCharges = paymentStatusData?.failedCharges,
                    let nextChargeDate = paymentStatusData?.nextChargeDate,
                    failedCharges > 0
                {
                    InfoCard(text: L10n.paymentsLatePaymentsMessage(failedCharges, nextChargeDate), type: .attention)
                        .buttons([
                            .init(
                                buttonTitle: L10n.PayInExplainer.buttonText,
                                buttonAction: {
                                    store.send(.connectPayments)
                                }
                            )
                        ])
                }
            }
        }
        .onAppear {
            store.send(.fetchPayInMethodStatus)
        }
    }
}
