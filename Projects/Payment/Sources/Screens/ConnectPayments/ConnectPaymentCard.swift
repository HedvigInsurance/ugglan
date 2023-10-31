import Foundation
import Presentation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI

public struct ConnectPaymentCardView: View {
    @PresentableStore var store: PaymentStore

    public init() {
        let store: PaymentStore = globalPresentableStoreContainer.get()
        store.send(.fetchPaymentStatus)
    }

    public var body: some View {
        PresentableStoreLens(
            PaymentStore.self,
            getter: { state in
                state.paymentStatusData
            }
        ) { paymentStatusData in
            if let nextChargeDate = paymentStatusData?.nextChargeDate?.displayDate,
                paymentStatusData?.status == .needsSetup
            {
                InfoCard(
                    text: L10n.InfoCardMissingPayment.bodyWithDate(nextChargeDate),
                    type: .attention
                )
                .buttons([
                    .init(
                        buttonTitle: L10n.PayInExplainer.buttonText,
                        buttonAction: {
                            store.send(.connectPayments)
                        }
                    )
                ])
            } else if paymentStatusData?.status == .needsSetup {
                InfoCard(text: L10n.InfoCardMissingPayment.body, type: .attention)
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
}
