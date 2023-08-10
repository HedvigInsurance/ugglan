import Flow
import Form
import Presentation
import SwiftUI
import UIKit
import hAnalytics
import hCore
import hCoreUI

struct PaymentView: View {
    let paymentType: hAnalytics.PaymentType
    @PresentableStore var store: PaymentStore
    var body: some View {
        hSection {
            paymentRowHeader
            paymentRow
            historyRow
        }
        .withoutHorizontalPadding
    }

    @ViewBuilder
    private var paymentRowHeader: some View {
        switch paymentType {
        case .trustly:
            PresentableStoreLens(
                PaymentStore.self,
                getter: { state in
                    state.paymentData
                }
            ) { paymentData in
                if let status = paymentData?.status,
                    status != .needsSetup,
                    paymentData?.bankAccount != nil
                {
                    hRow {
                        hText(L10n.PaymentDetails.NavigationBar.title)
                    }
                } else if paymentData?.paymentHistory?.count ?? 0 > 0 {
                    hRow {
                        hText(L10n.PaymentDetails.NavigationBar.title)
                    }
                }
            }
        case .adyen:
            PresentableStoreLens(
                PaymentStore.self,
                getter: { state in
                    state
                }
            ) { state in
                if let activePaymentData = state.activePaymentData,
                    activePaymentData.rowTitle != nil,
                    activePaymentData.rowValue != nil
                {
                    hRow {
                        hText(L10n.PaymentDetails.NavigationBar.title)
                    }
                } else if state.paymentData?.paymentHistory?.count ?? 0 > 0 {
                    hRow {
                        hText(L10n.PaymentDetails.NavigationBar.title)
                    }
                }
            }
        }
    }
    @ViewBuilder
    private var paymentRow: some View {
        switch paymentType {
        case .trustly:
            PresentableStoreLens(
                PaymentStore.self,
                getter: { state in
                    state.paymentData
                }
            ) { paymentData in
                if let status = paymentData?.status,
                    status != .needsSetup,
                    let bankAccount = paymentData?.bankAccount
                {
                    hRow {
                        HStack(spacing: 24) {
                            Image(uiImage: HCoreUIAsset.payments.image)
                                .resizable()
                                .frame(width: 24, height: 24)
                            hText(bankAccount.name ?? "")
                            Spacer()
                            hText(bankAccount.descriptor ?? "").foregroundColor(hLabelColor.secondary)
                        }
                    }
                }
            }
        case .adyen:
            PresentableStoreLens(
                PaymentStore.self,
                getter: { state in
                    state.activePaymentData
                }
            ) { activePaymentData in
                if let activePaymentData = activePaymentData,
                    let title = activePaymentData.rowTitle,
                    let subtitle = activePaymentData.rowValue
                {
                    hRow {
                        hText(title)
                        Spacer()
                        hText(subtitle)
                            .foregroundColor(hLabelColor.secondary)
                    }

                }
            }
        }
    }

    private var historyRow: some View {
        PresentableStoreLens(
            PaymentStore.self,
            getter: { state in
                state.paymentData?.paymentHistory
            }
        ) { history in
            hRow {
                HStack(spacing: 24) {
                    Image(uiImage: HCoreUIAsset.waiting.image)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .aspectRatio(contentMode: .fit)
                    hText(L10n.paymentsPaymentHistoryButtonLabel)
                }
            }
            .withChevronAccessory
            .onTap {
                store.send(.openHistory)
            }
            if paymentType == .trustly {
                PresentableStoreLens(
                    PaymentStore.self,
                    getter: { state in
                        state.paymentData
                    }
                ) { paymentData in
                    if let status = paymentData?.status,
                        status == .pending
                    {
                        hSection {
                            InfoCard(text: L10n.myPaymentUpdatingMessage, type: .info)
                        }
                    }
                }
            }
        }
    }
}

struct PaymentView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentView(paymentType: .trustly)
    }
}
