import Foundation
import Presentation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI

public struct ConnectPaymentCardView: View {
    @PresentableStore var store: PaymentStore

    public init() {}

    public var body: some View {
        VStack {
            switch hAnalyticsExperiment.paymentType {
            case .adyen:
                PresentableStoreLens(
                    PaymentStore.self,
                    getter: { state in
                        state
                    }
                ) { state in
                    if let failedCharges = state.paymentStatusData?.failedCharges,
                        let nextChargeDate = state.paymentStatusData?.nextChargeDate,
                        state.paymentStatusData == nil,
                        failedCharges > 0
                    {
                        InfoCard(
                            text: L10n.paymentsLatePaymentsMessage(failedCharges, nextChargeDate),
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
                    } else if state.paymentStatusData == nil {
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
            case .trustly:
                PresentableStoreLens(
                    PaymentStore.self,
                    getter: { state in
                        state.paymentStatusData
                    }
                ) { paymentStatusData in
                    if let failedCharges = paymentStatusData?.failedCharges,
                        let nextChargeDate = paymentStatusData?.nextChargeDate,
                        paymentStatusData?.status == .needsSetup,
                        failedCharges > 0
                    {
                        InfoCard(
                            text: L10n.paymentsLatePaymentsMessage(failedCharges, nextChargeDate),
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
        .onAppear {
            store.send(.fetchPaymentStatus)
        }
    }
}
