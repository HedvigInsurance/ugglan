import AppStateContainer
import Combine
import SwiftUI
import hCore
import hCoreUI

public struct PaymentsView: View {
    @AppObservedObject var store: PaymentStore
    @Environment(NavigationRouter.self) var router
    @Environment(PaymentsNavigationViewModel.self) var paymentNavigationVm
    @State var vm = PaymentsViewModel()

    public var body: some View {
        successView
            .loadingWithButtonLoading($vm.viewState)
            .hStateViewButtonConfig(
                .init(
                    actionButton: .init(buttonAction: {
                        vm.fetchData()
                    }),
                    dismissButton: nil
                )
            )
            .onAppear {
                store.markPaymentNoticeSeen()
                vm.fetchData()
            }
    }

    private var successView: some View {
        hForm {
            VStack(spacing: .padding16) {
                payments
                PaymentsMenuView()
            }
            .padding(.vertical, .padding8)
            .hButtonIsLoading(false)
        }
        .hSetScrollBounce(to: true)
        .onPullToRefresh {
            await store.fetchAllPaymentData(forceUpdate: true)
        }
    }

    private var payments: some View {
        VStack(spacing: .padding8) {
            if store.connectPaymentPrompt != nil {
                ConnectPaymentCardView(onConnectPayment: {
                    paymentNavigationVm.showAddPaymentMethod = true
                })
            } else if let missedPaymentData = store.missedPaymentData {
                MissedPaymentCardView(
                    amountDue: missedPaymentData.paymentData.payment.net,
                    onReviewPayment: {
                        router.push(missedPaymentData)
                    }
                )
                .padding(.bottom, .padding8)
            }
            if store.showsRetryChargeNotice {
                hSection {
                    InfoCard(text: L10n.paymentsRetryInfo, type: .neutral)
                }
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
        }
    }

    private struct PaymentView: View {
        let paymentData: PaymentData
        @Environment(NavigationRouter.self) var router
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
            .sectionContainerStyle(.primaryWithShadow)
        }
    }

    private struct PaymentsMenuView: View {
        @AppObservedObject var store: PaymentStore
        @Environment(NavigationRouter.self) var router

        var body: some View {
            if store.showsPayinSection,
                let paymentMethod = store.paymentStatusData?.defaultOrFirstDefaultPayinMethod
            {
                hSection {
                    PaymentMethodRow(paymentMethod, showsPrimaryLabel: false, allowsTapWhenPending: true) {
                        router.push(PaymentsRouterAction.paymentMethod(provider: paymentMethod.provider))
                    }
                }
                .withHeader(title: L10n.paymentMethodTitle)
                .sectionContainerStyle(.transparent)
            }
            hSection {
                if let payinMethods = store.paymentStatusData?.payinMethods, payinMethods.hasMethodInProgress {
                    InfoCard(text: L10n.paymentMethodPending, type: .neutral)
                }

                if store.paymentStatusData?.showsHistoricalSections ?? false {
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
                        hText(L10n.paymentMethodsTitle)
                        Spacer()
                    }
                    .withChevronAccessory
                    .onTap { router.push(PaymentsRouterAction.paymentMethods) }
                }

                if store.showsConnectPayout {
                    ConnectPayoutCardView {
                        router.push(PayoutRouterActions.selectedPayoutMethod)
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
                    .onTap { router.push(PayoutRouterActions.selectedPayoutMethod) }
                }
            }
            .sectionContainerStyle(.transparent)
            .hWithoutHorizontalPadding([.row, .divider])
        }
    }
}

@MainActor
@Observable
public class PaymentsViewModel {
    var viewState: ProcessingState = .loading
    @ObservationIgnored @AppState private var store: PaymentStore
    @ObservationIgnored private var fetchTask: Task<Void, Never>?
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()

    init() {
        store.$isFetchingPaymentStatus
            .combineLatest(store.$fetchPaymentStatusError)
            .receive(on: RunLoop.main)
            .map { isLoading, error in
                if isLoading { return .loading }
                if let error { return .error(errorMessage: error) }
                return .success
            }
            .sink { [weak self] state in
                self?.viewState = state
            }
            .store(in: &cancellables)
    }

    /// Fetches all payment data in an unstructured `Task` owned by the ViewModel.
    /// Called from `.onAppear` so it runs each time the view is presented, while
    /// being decoupled from the view's lifecycle — it survives the aggressive
    /// `.task` cancellation SwiftUI performs on iOS 18 during navigation transitions.
    func fetchData() {
        fetchTask?.cancel()
        let store = self.store
        fetchTask = Task {
            await store.fetchAllPaymentData()
        }
    }
}

#Preview {
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> hPaymentClient in hPaymentClientDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })

    return PaymentsNavigation(
        paymentsNavigationVm: PaymentsNavigationViewModel()
    )
    .environment(NavigationRouter())
}
