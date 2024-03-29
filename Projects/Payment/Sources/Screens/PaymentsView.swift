import Presentation
import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct PaymentsView: View {
    @PresentableStore var store: PaymentStore
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
                                        .foregroundColor(hTextColor.secondary)
                                }
                                .foregroundColor(.primary)
                                hText(upcomingPayment.payment.date.displayDate)
                                    .foregroundColor(hTextColor.secondary)
                            }
                        }
                        .withEmptyAccessory
                        .onTap {
                            store.send(
                                .navigation(
                                    to: .openPaymentDetails(
                                        data: upcomingPayment
                                    )
                                )
                            )
                        }
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(uiImage: hCoreUIAssets.infoSmall.image)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(hSignalColor.blueElement)
                        hText(L10n.paymentsNoPaymentsInProgress)
                    }
                    .padding(.vertical, 32)
                }
                hSection {
                    ConnectPaymentCardView()
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
            Image(uiImage: hCoreUIAssets.campaignSmall.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundColor(hSignalColor.greenElement)
            hText(L10n.paymentsDiscountsSectionTitle)
            Spacer()
        }
        .withChevronAccessory
        .onTap {
            store.send(.navigation(to: .openDiscounts))
        }
        .hWithoutHorizontalPadding
        .dividerInsets(.all, 0)

    }

    private var paymentHistory: some View {
        hRow {
            Image(uiImage: hCoreUIAssets.waiting.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundColor(hTextColor.primary)
            hText(L10n.paymentsPaymentHistoryButtonLabel)
            Spacer()
        }
        .withChevronAccessory
        .onTap {
            store.send(.navigation(to: .openHistory))
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
                .foregroundColor(hTextColor.primary)
            hText(displayName)
            Spacer()
        }
        .withCustomAccessory {
            hText(descriptor).foregroundColor(hTextColor.secondary)
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
            if let statusData, statusData != .needsSetup {
                hSection {
                    VStack(spacing: 16) {
                        if statusData == .pending {
                            InfoCard(text: L10n.myPaymentUpdatingMessage, type: .info)
                        }
                        hButton.LargeButton(type: .secondary) {
                            store.send(.navigation(to: .openConnectPayments))
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
        Dependencies.shared.add(module: Module { () -> hPaymentService in hPaymentServiceDemo() })
        return PaymentsView()
    }
}

extension PaymentsView {
    public func journey(schema: String) -> some JourneyPresentation {
        HostingJourney(
            PaymentStore.self,
            rootView: self
        ) { action in
            if case let .navigation(navigateTo) = action {
                if case .openHistory = navigateTo {
                    PaymentHistoryView.journey
                } else if case let .openPaymentDetails(details) = navigateTo {
                    PaymentDetailsView.journey(with: details)
                } else if case .openDiscounts = navigateTo {
                    PaymentsDiscountsRootView().journey
                }
            }
        }
        .configureTitle(L10n.myPaymentTitle)
        .configureTabBarItem(
            title: L10n.tabPaymentsTitle,
            image: hCoreUIAssets.paymentsTab.image,
            selectedImage: hCoreUIAssets.paymentsTab.image
        )
    }

    public func detentJourney(schema: String) -> some JourneyPresentation {
        HostingJourney(
            PaymentStore.self,
            rootView: self,
            style: .detented(.large),
            options: .largeNavigationBar
        ) { action in
            if case let .navigation(navigateTo) = action {
                if case .openConnectPayments = navigateTo {
                    DirectDebitSetup().journey()
                } else if case .openHistory = navigateTo {
                    PaymentHistoryView.journey
                } else if case let .openPaymentDetails(details) = navigateTo {
                    PaymentDetailsView.journey(with: details)
                } else if case .openDiscounts = navigateTo {
                    PaymentsDiscountsRootView().journey
                }
            }
        }
        .configureTitle(L10n.myPaymentTitle)
        .withJourneyDismissButton
    }
}
