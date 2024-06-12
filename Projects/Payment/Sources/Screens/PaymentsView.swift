import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct PaymentsView: View {
    @PresentableStore var store: PaymentStore
    @EnvironmentObject var router: Router
    @EnvironmentObject var paymentNavigationVm: PaymentsNavigationViewModel

    public init() {
        let store: PaymentStore = globalPresentableStoreContainer.get()
        store.send(.load)
        store.send(.fetchPaymentStatus)
    }

    public var body: some View {
        LoadingViewWithContent(
            PaymentStore.self,
            [.getPaymentData],
            [.load, .fetchPaymentStatus]
        ) {
            hForm {
                VStack(spacing: 8) {
                    upcomingPayment
                    PresentableStoreLens(
                        PaymentStore.self,
                        getter: { state in
                            state.paymentStatusData
                        }
                    ) { statusData in
                        if let displayName = statusData?.displayName, let descriptor = statusData?.descriptor {
                            hSection {
                                discounts
                                paymentHistory
                                connectedPaymentMethod(displayName: displayName, descriptor: descriptor)
                            }
                        } else {
                            hSection {
                                discounts
                                paymentHistory
                            }
                        }

                    }
                    .sectionContainerStyle(.transparent)

                }
                .padding(.vertical, 8)
            }
            .hFormAttachToBottom {
                bottomPart
            }
            .onPullToRefresh {
                await store.sendAsync(.load)
                await store.sendAsync(.fetchPaymentStatus)
            }
        }
    }

    private var upcomingPayment: some View {
        PresentableStoreLens(
            PaymentStore.self,
            getter: { state in
                state
            }
        ) { state in
            VStack(spacing: 8) {
                if let upcomingPayment = state.paymentData {
                    hSection {
                        hRow {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(alignment: .center, spacing: 8) {
                                    hText(L10n.paymentsUpcomingPayment)
                                    Spacer()
                                    hText(upcomingPayment.payment.net.formattedAmount)
                                    Image(uiImage: hCoreUIAssets.chevronRightSmall.image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 16, height: 16)
                                        .foregroundColor(hTextColor.Opaque.secondary)
                                }
                                .foregroundColor(.primary)
                                hText(upcomingPayment.payment.date.displayDate)
                                    .foregroundColor(hTextColor.Opaque.secondary)
                            }
                        }
                        .withEmptyAccessory
                        .onTap {
                            router.push(upcomingPayment)
                        }
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(uiImage: hCoreUIAssets.infoFilledSmall.image)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(hSignalColor.Blue.element)
                        hText(L10n.paymentsNoPaymentsInProgress)
                    }
                    .padding(.vertical, 32)
                }
                hSection {
                    ConnectPaymentCardView()
                        .environmentObject(paymentNavigationVm.connectPaymentVm)
                }
                if let status = state.paymentData?.status, status != .upcoming {
                    hSection {
                        PaymentStatusView(status: status) { _ in

                        }
                    }
                }
            }
        }
    }

    private var discounts: some View {
        hRow {
            Image(uiImage: hCoreUIAssets.campaign.image)
                .foregroundColor(hSignalColor.Green.element)
            hText(L10n.paymentsDiscountsSectionTitle)
            Spacer()
        }
        .withChevronAccessory
        .onTap {
            router.push(PaymentsRouterAction.discounts)
        }
        .hWithoutHorizontalPadding
        .dividerInsets(.all, 0)

    }

    private var paymentHistory: some View {
        hRow {
            Image(uiImage: hCoreUIAssets.clock.image)
                .foregroundColor(hTextColor.Opaque.primary)
            hText(L10n.paymentsPaymentHistoryButtonLabel)
            Spacer()
        }
        .withChevronAccessory
        .onTap {
            router.push(PaymentsRouterAction.history)
        }
        .hWithoutHorizontalPadding
        .dividerInsets(.all, 0)
    }

    @ViewBuilder
    private func connectedPaymentMethod(displayName: String, descriptor: String) -> some View {
        hRow {
            Image(uiImage: hCoreUIAssets.payments.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundColor(hTextColor.Opaque.primary)
            hText(displayName)
            Spacer()
        }
        .withCustomAccessory {
            hText(descriptor).foregroundColor(hTextColor.Opaque.secondary)
        }
        .hWithoutHorizontalPadding
        .dividerInsets(.all, 0)
    }

    private var bottomPart: some View {
        PresentableStoreLens(
            PaymentStore.self,
            getter: { state in
                state.paymentStatusData?.status
            }
        ) { statusData in
            if let statusData, !statusData.showConnectPayment {
                hSection {
                    VStack(spacing: 16) {
                        if statusData == .pending {
                            InfoCard(text: L10n.myPaymentUpdatingMessage, type: .info)
                        }
                        hButton.LargeButton(type: .secondary) {
                            paymentNavigationVm.connectPaymentVm.set(for: nil)
                        } content: {
                            hText(statusData.connectButtonTitle)
                        }
                        .padding(.bottom, 16)
                    }
                }
                .sectionContainerStyle(.transparent)
            }
        }
    }
}

struct PaymentsView_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale = .en_SE
        Dependencies.shared.add(module: Module { () -> hPaymentClient in hPaymentClientDemo() })
        return PaymentsView()
    }
}
