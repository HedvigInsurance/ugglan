import Combine
import PresentableStore
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

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
        successView.loading($vm.viewState, showLoading: false)
            .hErrorViewButtonConfig(
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
            .padding(.vertical, .padding8)
        }
        .hFormAttachToBottom {
            bottomPart
        }
        .onPullToRefresh {
            await store.sendAsync(.fetchPaymentStatus)
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
                    .padding(.vertical, .padding32)
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
                        .padding(.bottom, .padding16)
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
    @Published var actionCancellable: AnyCancellable?
    @Published var loadingCancellable: AnyCancellable?

    init() {
        actionCancellable = store.actionSignal
            .receive(on: RunLoop.main)
            .sink { _ in
            } receiveValue: { [weak self] action in
                if action == .load || action == .fetchPaymentStatus {
                    self?.viewState = .success
                }
            }

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
                default: break
                }
            }
    }
}

struct PaymentsView_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale.send(.en_SE)
        Dependencies.shared.add(module: Module { () -> hPaymentClient in hPaymentClientDemo() })
        return PaymentsView()
    }
}
