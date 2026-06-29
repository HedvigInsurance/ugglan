import AppStateContainer
import Combine
import SwiftUI
import hCore
import hCoreUI

public struct PaymentsView: View {
    @AppObservedObject var store: PaymentStore
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var paymentNavigationVm: PaymentsNavigationViewModel
    @StateObject var vm = PaymentsViewModel()

    public var body: some View {
        successView
            .loadingWithButtonLoading($vm.viewState)
            .hStateViewButtonConfig(
                .init(
                    actionButton: .init(buttonAction: {
                        Task {
                            async let load: () = store.load()
                            async let fetchStatus: () = store.fetchPaymentStatus()
                            async let missedPayment: () = store.getMissedPayment()
                            _ = await (load, fetchStatus, missedPayment)
                        }
                    }),
                    dismissButton: nil
                )
            )
            .task {
                async let load: () = store.load()
                async let fetchStatus: () = store.fetchPaymentStatus()
                async let missedPayment: () = store.getMissedPayment()
                _ = await (load, fetchStatus, missedPayment)
            }
    }

    private var successView: some View {
        hForm {
            VStack(spacing: .padding8) {
                payments
                PaymentsMenuView()
            }
            .padding(.vertical, .padding8)
            .hButtonIsLoading(false)
        }
        .hSetScrollBounce(to: true)
        .hFormAttachToBottom {
            if store.showsConnectPayment {
                ConnectPaymentBottomView()
            }
        }
        .onPullToRefresh {
            async let fetchStatus: () = store.fetchPaymentStatus()
            async let load: () = store.load()
            async let missedPayment: () = store.getMissedPayment()
            _ = await (fetchStatus, load, missedPayment)
        }
    }

    private var payments: some View {
        VStack(spacing: .padding8) {
            if let missedPaymentData = store.missedPaymentData {
                MissedPaymentCardView(
                    amountDue: missedPaymentData.paymentData.payment.net,
                    onReviewPayment: {
                        router.push(missedPaymentData)
                    }
                )
                .padding(.bottom, .padding8)
            }
            if !store.ongoingPaymentData.isEmpty {
                ForEach(store.ongoingPaymentData, id: \.id) { paymentData in
                    PaymentView(paymentData: paymentData)
                }
            }
            if let upcomingPayment = store.paymentData {
                PaymentView(paymentData: upcomingPayment)
            }

            if store.ongoingPaymentData.isEmpty, store.showsNoPaymentsInProgress {
                VStack(spacing: 16) {
                    hCoreUIAssets.infoFilledSmall.view
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(hSignalColor.Blue.element)
                    hText(L10n.paymentsNoPaymentsInProgress)
                }
                .padding(.vertical, .padding32)
            }
            if store.showsConnectPayment {
                hSection {
                    ConnectPaymentCardView()
                        .environmentObject(paymentNavigationVm.connectPaymentVm)
                }
            }
        }
    }

    private struct PaymentView: View {
        let paymentData: PaymentData
        @EnvironmentObject var router: NavigationRouter
        var body: some View {
            hSection {
                hRow {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .top, spacing: 8) {
                            hText(
                                paymentData.status == .upcoming
                                    ? L10n.paymentsUpcomingPayment : L10n.paymentsProcessingPayment
                            )
                            Spacer()
                            hText(paymentData.payment.net.formattedAmount)
                            Image(uiImage: hCoreUIAssets.chevronRight.image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundColor(hTextColor.Opaque.secondary)
                                .accessibilityHidden(true)
                        }
                        .foregroundColor(.primary)
                        hText(paymentData.payment.date.displayDate)
                            .foregroundColor(hTextColor.Opaque.secondary)
                    }
                }
                .withEmptyAccessory
                .onTap {
                    router.push(paymentData)
                }
            }
        }
    }

    private struct PaymentsMenuView: View {
        @AppObservedObject var store: PaymentStore
        @EnvironmentObject var router: NavigationRouter

        var body: some View {
            let showsHistoricalSections = store.paymentStatusData?.showsHistoricalSections ?? false
            hSection {
                if showsHistoricalSections {
                    hRow {
                        hCoreUIAssets.campaign.view
                            .foregroundColor(hSignalColor.Green.element)
                        hText(L10n.paymentsDiscountsSectionTitle)
                        Spacer()
                    }
                    .withChevronAccessory
                    .onTap {
                        router.push(PaymentsRouterAction.discounts)
                    }
                    hRow {
                        hCoreUIAssets.clock.view
                            .foregroundColor(hTextColor.Opaque.primary)
                        hText(L10n.paymentsPaymentHistoryButtonLabel)
                        Spacer()
                    }
                    .withChevronAccessory
                    .onTap {
                        router.push(PaymentsRouterAction.history)
                    }
                }
                if store.showsPayinSection {
                    hRow {
                        hCoreUIAssets.payments.view
                            .foregroundColor(hTextColor.Opaque.primary)
                        hText(L10n.PaymentDetails.NavigationBar.title)
                        Spacer()
                    }
                    .withChevronAccessory
                    .onTap {
                        router.push(PaymentsRouterAction.paymentMethod)
                    }
                }

                if store.showsConnectPayout {
                    ConnectPayoutCardView { [weak router] in
                        router?.push(PayoutRouterActions.selectedPayoutMethod)
                    }
                }

                if store.showsPayoutSection {
                    hRow {
                        hCoreUIAssets.paymentOutlined.view
                            .foregroundColor(hTextColor.Opaque.primary)
                        hText(L10n.payoutPageHeading)
                        Spacer()
                    }
                    .withChevronAccessory
                    .onTap { [weak router] in router?.push(PaymentsRouterAction.payoutMethod) }
                }
            }
            .sectionContainerStyle(.transparent)
            .hWithoutHorizontalPadding([.row, .divider])
        }
    }
}

@MainActor
public class PaymentsViewModel: ObservableObject {
    @Published var viewState: ProcessingState = .loading
    @AppState private var store: PaymentStore

    init() {
        store.$isFetchingPaymentStatus
            .combineLatest(store.$fetchPaymentStatusError)
            .receive(on: RunLoop.main)
            .map { isLoading, error in
                if isLoading { return .loading }
                if let error { return .error(errorMessage: error) }
                return .success
            }
            .assign(to: &$viewState)
    }
}

#Preview {
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> hPaymentClient in hPaymentClientDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })

    return PaymentsNavigation(
        paymentsNavigationVm: PaymentsNavigationViewModel()
    )
    .environmentObject(NavigationRouter())
}
