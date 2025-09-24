import Combine
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

public struct PaymentsView: View {
    @PresentableStore var store: PaymentStore
    @EnvironmentObject var router: Router
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
            .padding(.vertical, .padding8)
        }
        .hSetScrollBounce(to: true)
        .hFormAttachToBottom {
            bottomPart
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
        ) { state in
            VStack(spacing: 8) {
                if !state.ongoingPaymentData.isEmpty {
                    ForEach(state.ongoingPaymentData, id: \.id) { paymentData in
                        paymentView(for: paymentData)
                    }
                }
                if let upcomingPayment = state.paymentData {
                    paymentView(for: upcomingPayment)
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
                        .environmentObject(paymentNavigationVm.connectPaymentVm)
                }
            }
        }
    }

    private func paymentView(for paymentData: PaymentData) -> some View {
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

    private var discounts: some View {
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
        .hWithoutHorizontalPadding([.row])
        .dividerInsets(.all, 0)
    }

    private var paymentHistory: some View {
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
        .hWithoutHorizontalPadding([.row])
        .dividerInsets(.all, 0)
    }

    @ViewBuilder
    private func connectedPaymentMethod(displayName: String, descriptor: String) -> some View {
        hRow {
            hCoreUIAssets.payments.view
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
        .hWithoutHorizontalPadding([.row])
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
                    VStack(spacing: .padding16) {
                        if statusData == .pending {
                            InfoCard(text: L10n.myPaymentUpdatingMessage, type: .info)
                        }
                        hButton(
                            .large,
                            .secondary,
                            content: .init(title: statusData.connectButtonTitle),
                            {
                                paymentNavigationVm.connectPaymentVm.set(for: nil)
                            }
                        )
                    }
                }
                .sectionContainerStyle(.transparent)
            }
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

struct PaymentsView_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale.send(.en_SE)
        Dependencies.shared.add(module: Module { () -> hPaymentClient in hPaymentClientDemo() })
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        return PaymentsView().environmentObject(PaymentsNavigationViewModel())
    }
}
