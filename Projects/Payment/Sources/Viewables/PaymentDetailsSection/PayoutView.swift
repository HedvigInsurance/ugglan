import Flow
import Form
import Presentation
import SwiftUI
import UIKit
import hAnalytics
import hCore
import hCoreUI

struct PayoutView: View {
    @PresentableStore var store: PaymentStore
    let paymentType: hAnalytics.PaymentType

    var body: some View {
        hSection {
            payoutRow.trackLoading(PaymentStore.self, action: .getAdyenAvailableMethodsForPayout)
        }
        .withoutHorizontalPadding
    }

    private var payoutRow: some View {

        PresentableStoreLens(
            PaymentStore.self,
            getter: { state in
                state.activePayoutData
            }
        ) { payoutData in
            if paymentType == .adyen {
                if let status = payoutData?.status {
                    switch status {
                    case .active:
                        activePayoutRow
                    case .needsSetup:
                        needSetupPayoutRow
                    case .pending:
                        pendingPayoutRow
                    case .__unknown: Color.clear.frame(height: 1)
                    }

                }
            }
        }
    }

    @RowViewBuilder
    private var activePayoutRow: some View {
        hRow {
            hText(L10n.PaymentScreen.payoutSectionTitle)
        }
        hRow {
            Image(uiImage: hCoreUIAssets.circularCheckmark.image).resizable().frame(width: 24, height: 24)
            hText(L10n.PaymentScreen.payConnectedLabel)
        }

        hRow {
            hText(L10n.PaymentScreen.payOutConnectedPayoutFooterConnected)
        }

        hRow {
            hButton.LargeButton(type: .ghost) {
                store.send(.fetchAdyenAvailableMethodsForPayout)
            } content: {
                hText(L10n.PaymentScreen.payOutChangePayoutButton)
            }
        }
    }

    @RowViewBuilder
    private var pendingPayoutRow: some View {
        hRow {
            hText(L10n.PaymentScreen.payoutSectionTitle)
        }
        hRow {
            hText(L10n.PaymentScreen.payOutProcessing)
        }
        .hWithoutDivider

        InfoCard(text: L10n.PaymentScreen.PayOut.footerPending, type: .info)
            .padding(.horizontal, 16)
        hButton.LargeButton(type: .ghost) {
            store.send(.fetchAdyenAvailableMethodsForPayout)
        } content: {
            hText(L10n.PaymentScreen.payOutChangePayoutButton)
        }
    }

    @RowViewBuilder
    private var needSetupPayoutRow: some View {
        hRow {
            hText(L10n.PaymentScreen.payoutSectionTitle)
        }
        hRow {
            hText(L10n.PaymentScreen.payOutFooterNotConnected)
        }
        hButton.LargeButton(type: .ghost) {
            store.send(.fetchAdyenAvailableMethodsForPayout)
        } content: {
            hText(L10n.PaymentScreen.payOutChangePayoutButton)
        }
    }
}

struct PayoutView_Previews: PreviewProvider {
    static var previews: some View {
        PayoutView(paymentType: .adyen)
    }
}
