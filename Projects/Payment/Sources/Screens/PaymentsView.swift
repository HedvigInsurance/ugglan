import Combine
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct PaymentsView: View {
    @PresentableStore var store: PaymentStore
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var paymentNavigationVm: PaymentsNavigationViewModel
    @StateObject var vm = PaymentsViewModel()

    public init() {
        let store: PaymentStore = globalPresentableStoreContainer.get()
        store.send(.load)
        store.send(.fetchPaymentStatus)
    }

    public var body: some View {
        successView
            .loadingWithButtonLoading($vm.viewState)
            .hStateViewButtonConfig(
                .init(
                    actionButton: .init(buttonAction: {
                        store.send(.load)
                        store.send(.fetchPaymentStatus)
                    }),
                    dismissButton: nil
                )
            )
    }

    private var successView: some View {
        hForm {
            VStack(spacing: 8) {
                payments
                PresentableStoreLens(
                    PaymentStore.self,
                    getter: { state in
                        state.paymentStatusData
                    }
                ) { paymentStatusData in
                    if let paymentStatusData {
                        PaymentsMenuView(paymentStatusData: paymentStatusData)
                    }
                }
            }
            .padding(.vertical, .padding8)
        }
        .hSetScrollBounce(to: true)
        .hFormAttachToBottom {
            PresentableStoreLens(
                PaymentStore.self,
                getter: { state in
                    state.paymentStatusData
                }
            ) { statusData in
                if let statusData, statusData.payinMethods.isEmpty {
                    ConnectPaymentBottomView()
                }
            }
        }
        .onPullToRefresh {
            await store.send(.fetchPaymentStatus)
            await store.send(.load)
        }
    }

    private var payments: some View {
        PresentableStoreLens(
            PaymentStore.self,
            getter: { state in
                state
            }
        ) { [weak paymentNavigationVm] state in
            VStack(spacing: 8) {
                if !state.ongoingPaymentData.isEmpty {
                    ForEach(state.ongoingPaymentData, id: \.id) { paymentData in
                        PaymentView(paymentData: paymentData)
                    }
                }
                if let upcomingPayment = state.paymentData {
                    PaymentView(paymentData: upcomingPayment)
                }

                if state.ongoingPaymentData.isEmpty, state.paymentData == nil {
                    VStack(spacing: 16) {
                        hCoreUIAssets.infoFilledSmall.view
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(hSignalColor.Blue.element)
                        hText(L10n.paymentsNoPaymentsInProgress)
                    }
                    .padding(.vertical, .padding32)
                }

                hSection {
                    ConnectPaymentCardView()
                        .environmentObject(paymentNavigationVm!.connectPaymentVm)
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
        @EnvironmentObject var router: NavigationRouter
        let paymentStatusData: PaymentStatusData

        var body: some View {
            hSection {
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
                if paymentStatusData.showPayinSection {
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

                if paymentStatusData.showPayoutSection {
                    hRow {
                        hCoreUIAssets.paymentOutlined.view
                            .foregroundColor(hTextColor.Opaque.primary)
                        hText(L10n.payoutPageHeading)
                        Spacer()
                    }
                    .withChevronAccessory
                    .onTap { [weak router] in
                        router?.push(PaymentsRouterAction.payoutMethod)
                    }
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
    @PresentableStore var store: PaymentStore
    @Published var loadingCancellable: AnyCancellable?

    init() {
        loadingCancellable = store.loadingSignal
            .receive(on: RunLoop.main)
            .sink { _ in
            } receiveValue: { [weak self] action in
                let getAction = action.first(where: { $0.key == .getPaymentStatus })
                switch getAction?.value {
                case let .error(errorMessage):
                    self?.viewState = .error(errorMessage: errorMessage)
                case .loading:
                    self?.viewState = .loading
                default:
                    self?.viewState = .success
                }
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
    .environmentObject(NavigationRouter())
}
