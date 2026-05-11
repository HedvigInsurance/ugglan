import PresentableStore
import SwiftUI
import hCore
import hCoreUI

@MainActor
extension View {
    public func handleMissedPayment(data: Binding<MissedPaymentData?>) -> some View {
        self.detent(
            item: data,
            presentationStyle: .detent(style: [.large]),
            options: .constant(.alwaysOpenOnTop)
        ) { missedPaymentData in
            MissedPaymentScreen(
                missedPaymentdata: missedPaymentData,
                onSuccess: {
                    data.wrappedValue = nil
                }
            )
            .withDismissButton()
            .navigationTitle(L10n.paymentsPaymentOverdueTitle)
            .routerDestination(for: PaymentData.self) { paymentData in
                PaymentDetailsView(data: paymentData)
            }
            .embededInNavigation(tracking: missedPaymentData)
        }
    }
}

struct MissedPaymentScreen: View {
    let missedPaymentdata: MissedPaymentData
    @PresentableStore var paymentStore: PaymentStore
    @StateObject private var vm = PaymentOverdueScreenViewModel()
    @EnvironmentObject var router: NavigationRouter
    let onSuccess: () -> Void

    var body: some View {
        hForm {
            VStack(spacing: .padding16) {
                CardView {
                    overdueCard
                        .padding(.padding16)
                }
                .padding(.top, .padding8)
                if showInfoMesaage {
                    hSection {
                        infoCard
                    }
                }
            }
            .sectionContainerStyle(.negative)
        }
        .trackErrorState(for: $vm.processingState, errorTitle: L10n.selfManualChargeChangesBeenMadeTitle)
        .hStateViewButtonConfig(
            .init(
                actionButton: .init(
                    buttonTitle: L10n.openChat,
                    buttonAction: { [weak router] in
                        router?.popToRoot()
                        router?.dismiss()
                        NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
                    }
                ),
                actionButtonAttachedToBottom: .init(
                    buttonTitle: L10n.generalCloseButton,
                    buttonStyle: .secondary,
                    buttonAction: { [weak router] in
                        router?.popToRoot()
                        router?.dismiss()
                    }
                )
            )
        )
        .disabled(vm.processingState == .loading)
        .modally(
            presented: $vm.showSuccessScreen
        ) {
            StateView(
                type: showInfoMesaage ? .error : .success,
                title: L10n.paymentsPaymentInProgress,
                bodyText: L10n.paymentsPaymentInProgressDescription,
                formPosition: .center
            )
            .hStateViewButtonConfig(
                .init(
                    actionButtonAttachedToBottom: .init(
                        buttonTitle: L10n.generalDoneButton,
                        buttonStyle: .secondary,
                        buttonAction: { [weak vm] in
                            vm?.showSuccessScreen = false
                        }
                    )
                )
            )
            .hStateViewContentBottomAttachedView {
                if showInfoMesaage {
                    infoCard
                }
            }
            .withDismissButton()
            .embededInNavigation(tracking: String(describing: SuccessScreen.self))
            .onDeinit {
                let store: PaymentStore = globalPresentableStoreContainer.get()
                store.send(.setMissedPaymentData(data: nil))
                Task { @MainActor in
                    onSuccess()
                }
            }
        }
    }

    private var overdueCard: some View {
        VStack(alignment: .leading, spacing: .padding16) {
            titleSection
            viewPaymentDetailsButton
            infoSection
        }
    }

    private var titleSection: some View {
        HStack(alignment: .center, spacing: .padding12) {
            hCoreUIAssets.warningTriangleFilled.view
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(hSignalColor.Red.element)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 0) {
                hText(
                    L10n.paymentsPaymentOverdueDetailsSince(
                        missedPaymentdata.paymentData.payment.date.displayDateShort
                    ),
                    style: .heading1
                )
                .foregroundColor(hTextColor.Opaque.primary)
                hText(L10n.paymentsPaymentOverdueDetailsBody, style: .heading1)
                    .foregroundColor(hTextColor.Opaque.secondary)
            }
            Spacer()
        }
        .accessibilityElement(children: .combine)
    }

    private var viewPaymentDetailsButton: some View {
        hButton(
            .medium,
            .ghost,
            content: .init(title: L10n.paymentsPaymentOverdueDetailsViewDetails),
            { [weak router] in
                router?.push(missedPaymentdata.paymentData)
            }
        )
        .hButtonTakeFullWidth(true)
        .hButtonWithBorder
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: .padding16) {
            infoRows
            hRowDivider()
                .dividerInsets(.all, 0)
            totalRow
            VStack(spacing: .padding6) {
                payButton
                finePrint
            }
        }
    }

    private var infoRows: some View {
        VStack(alignment: .leading, spacing: .padding4) {
            infoRow(
                label: L10n.paymentsPaymentOverdueDetailsDueDate,
                value: missedPaymentdata.paymentData.payment.date.displayDate
            )
            infoRow(
                label: L10n.bankPayoutMethodCardTitle,
                value: missedPaymentdata.paymentMethodData.info
            )
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            hText(label, style: .label)
                .foregroundColor(hTextColor.Opaque.secondary)
            Spacer()
            hText(value, style: .label)
                .foregroundColor(hTextColor.Opaque.secondary)
        }
        .accessibilityElement(children: .combine)
    }

    private var totalRow: some View {
        HStack {
            hText(L10n.PaymentDetails.ReceiptCard.total, style: .heading1)
                .foregroundColor(hTextColor.Opaque.primary)
            Spacer()
            hText(missedPaymentdata.paymentData.payment.net.formattedAmount, style: .heading1)
                .foregroundColor(hTextColor.Opaque.primary)
        }
        .accessibilityElement(children: .combine)
    }

    private var payButton: some View {
        hButton(
            .medium,
            .primary,
            content: .init(
                title: L10n.paymentsPaymentOverdueDetailsPay(missedPaymentdata.paymentData.payment.net.formattedAmount)
            ),
            { [weak vm] in
                vm?.chargeOutstandingPayment()
            }
        )
        .hButtonTakeFullWidth(true)
        .hButtonIsLoading(vm.processingState == .loading)
    }

    private var finePrint: some View {
        hText(L10n.paymentsPaymentOverdueDetailsFinePrint, style: .finePrint)
            .foregroundColor(hTextColor.Translucent.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }

    private var infoCard: some View {
        InfoCard(
            text: L10n.manualChargeCancellationWarning,
            type: .attention
        )
    }

    private var showInfoMesaage: Bool {
        if case .contactUs = paymentStore.state.paymentStatusData?.status { return true }
        return false
    }
}

@MainActor
class PaymentOverdueScreenViewModel: ObservableObject {
    private let paymentService = hPaymentService()
    @Published var processingState: ProcessingState = .success
    @Published var showSuccessScreen = false

    func chargeOutstandingPayment() {
        processingState = .loading
        Task {
            do {
                try await self.paymentService.chargeOutstandingPayment()
                self.processingState = .success
                self.showSuccessScreen = true
            } catch {
                self.processingState = .error(errorMessage: error.localizedDescription)
            }
        }
    }
}

#Preview {
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    let paymentData = PaymentData(
        id: "id",
        payment: .init(
            gross: .sek(493.93),
            net: .sek(493.93),
            carriedAdjustment: nil,
            settlementAdjustment: nil,
            date: "2026-04-30"
        ),
        status: .addedtoFuture(date: "2026-05-30"),
        contracts: [],
        referralDiscount: nil,
        amountPerReferral: .sek(10),
        payinMethod: .init(
            provider: .trustly,
            status: .active,
            isDefault: true,
            details: .bankAccount(account: "account", bank: "bank")
        ),
        addedToThePayment: nil
    )

    let store: PaymentStore = globalPresentableStoreContainer.get()
    store.send(
        .setPaymentStatus(
            data: .init(
                status: .contactUs(date: "22. maj 2026."),
                chargingDay: 27,
                defaultPayinMethod: nil,
                payinMethods: [],
                defaultPayoutMethod: nil,
                payoutMethods: [],
                availableMethods: []
            )
        )
    )
    return MissedPaymentScreen(
        missedPaymentdata: .init(
            paymentData: paymentData,
            paymentMethodData: .init(
                provider: .trustly,
                status: .active,
                isDefault: true,
                details: .bankAccount(account: "account", bank: "bank")
            )
        ),
        onSuccess: {}
    )
    .environmentObject(NavigationRouter())
}
