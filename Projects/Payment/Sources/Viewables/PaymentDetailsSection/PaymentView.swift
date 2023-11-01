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
        PresentableStoreLens(
            PaymentStore.self,
            getter: { state in
                state
            }
        ) { state in
            if state.paymentStatusData?.status != .needsSetup,
                state.paymentStatusData?.displayName != nil
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

    @ViewBuilder
    private var paymentRow: some View {
        switch paymentType {
        case .trustly:
            PresentableStoreLens(
                PaymentStore.self,
                getter: { state in
                    state.paymentStatusData
                }
            ) { paymentStatusData in
                if let statusData = paymentStatusData,
                    statusData.status != .needsSetup
                {
                    hRow {
                        HStack(spacing: 24) {
                            Image(uiImage: HCoreUIAsset.payments.image)
                                .resizable()
                                .frame(width: 24, height: 24)
                            hText(statusData.displayName ?? "")
                            Spacer()
                            hText(statusData.descriptor ?? "").foregroundColor(hTextColor.secondary)
                        }
                    }
                }
            }
        case .adyen:
            PresentableStoreLens(
                PaymentStore.self,
                getter: { state in
                    state.paymentStatusData
                }
            ) { paymentStatusData in
                if let paymentStatusData = paymentStatusData,
                    let title = paymentStatusData.displayName,
                    let subtitle = paymentStatusData.descriptor
                {
                    hRow {
                        hText(title)
                        Spacer()
                        hText(subtitle)
                            .foregroundColor(hTextColor.secondary)
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
            .padding(.bottom, 16)
            if paymentType == .trustly {
                PresentableStoreLens(
                    PaymentStore.self,
                    getter: { state in
                        state.paymentStatusData
                    }
                ) { statusData in
                    if let status = statusData?.status,
                        status == .pending
                    {
                        hSection {
                            InfoCard(text: L10n.myPaymentUpdatingMessage, type: .info)
                        }
                        .padding(.bottom, 16)
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
