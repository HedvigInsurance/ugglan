import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct ConnectPaymentBottomView: View {
    @EnvironmentObject var paymentNavigationVm: PaymentsNavigationViewModel

    var body: some View {
        PresentableStoreLens(
            PaymentStore.self,
            getter: { state in
                state
            }
        ) { state in
            if let statusData = state.paymentStatusData, state.showChangePayinMethod {
                hSection {
                    VStack(spacing: .padding16) {
                        if statusData.payinMethods.hasMethodInProgress {
                            InfoCard(text: L10n.myPaymentUpdatingMessage, type: .info)
                        }
                        hButton(
                            .large,
                            .secondary,
                            content: .init(title: statusData.status.connectButtonTitle),
                            { [weak paymentNavigationVm] in
                                paymentNavigationVm?.connectPaymentVm.set()
                            }
                        )
                    }
                }
                .sectionContainerStyle(.transparent)
            }
        }
    }
}
