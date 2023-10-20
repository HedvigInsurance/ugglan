import Foundation
import Presentation
import SwiftUI
import hAnalytics
import hCore
import hCoreUI

public struct ConnectPaymentCardView: View {
    @PresentableStore var store: PaymentStore

    public init() {
        switch hAnalyticsExperiment.paymentType {
        case .adyen:
            store.send(.fetchActivePayment)
        case .trustly:
            store.send(.fetchPayInMethodStatus)
        }
    }

    public var hasActiveInfoCard: Bool {
        switch hAnalyticsExperiment.paymentType {
        case .adyen:
            if ConnectPaymentModelAdyen().hasFailed || ConnectPaymentModelAdyen().missingPaymentData {
                return true
            }
            return false
        case .trustly:
            if ConnectPaymentModelTrustly().hasFailed || ConnectPaymentModelTrustly().needsSetUp {
                return true
            }
            return false
        }
    }

    struct ConnectPaymentModelAdyen {
        var hasFailed: Bool = false
        var failedCharges = 0
        var nextChargeDate = ""
        var missingPaymentData = false

        init() {
            let paymentStore: PaymentStore = globalPresentableStoreContainer.get()
            let state = paymentStore.state
            let paymentStatusData = state.paymentStatusData

            if let failedCharges = paymentStatusData?.failedCharges,
                let nextChargeDate = paymentStatusData?.nextChargeDate,
                state.activePaymentData == nil,
                failedCharges > 0
            {
                self.hasFailed = true
                self.failedCharges = failedCharges
                self.nextChargeDate = nextChargeDate
            } else if state.activePaymentData == nil {
                self.missingPaymentData = true
            }
        }
    }

    struct ConnectPaymentModelTrustly {
        var hasFailed: Bool = false
        var failedCharges = 0
        var nextChargeDate = ""
        var needsSetUp = false

        init() {
            let paymentStore: PaymentStore = globalPresentableStoreContainer.get()
            let state = paymentStore.state

            let paymentStatusData = state.paymentStatusData
            if let failedCharges = paymentStatusData?.failedCharges,
                let nextChargeDate = paymentStatusData?.nextChargeDate,
                paymentStatusData?.status == .needsSetup,
                failedCharges > 0
            {
                self.hasFailed = true
                self.failedCharges = failedCharges
                self.nextChargeDate = nextChargeDate
            } else if paymentStatusData?.status == .needsSetup {
                needsSetUp = true
            }
        }
    }

    public var body: some View {
        VStack {
            switch hAnalyticsExperiment.paymentType {
            case .adyen:
                if ConnectPaymentModelAdyen().hasFailed {
                    InfoCard(
                        text: L10n.paymentsLatePaymentsMessage(
                            ConnectPaymentModelAdyen().failedCharges,
                            ConnectPaymentModelAdyen().nextChargeDate
                        ),
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
                } else if ConnectPaymentModelAdyen().missingPaymentData {
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
            case .trustly:
                if ConnectPaymentModelTrustly().hasFailed {
                    InfoCard(
                        text: L10n.paymentsLatePaymentsMessage(
                            ConnectPaymentModelTrustly().failedCharges,
                            ConnectPaymentModelTrustly().nextChargeDate
                        ),
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
                } else if ConnectPaymentModelTrustly().needsSetUp {
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
}
