import SwiftUI
import hCore
import hCoreUI

struct MissedPaymentScreen: View {
    let missedPaymentdata: MissedPaymentData
    @EnvironmentObject var router: NavigationRouter
    @State private var showPaymentDetails = false
    @StateObject private var vm = PaymentOverdueScreenViewModel()

    var body: some View {
        hForm {
            hSection {
                overdueCard
                    .padding(.padding16)
                    .overlay(
                        RoundedRectangle(cornerRadius: .cornerRadiusXL)
                            .inset(by: 0.5)
                            .stroke(hBorderColor.primary, lineWidth: 1)

                    )
            }
            .sectionContainerStyle(.negative)
            .cornerRadius(.cornerRadiusXL)
            .hShadow(type: .custom(opacity: 0.05, radius: 5, xOffset: 0, yOffset: 4), show: true)
            .hShadow(type: .custom(opacity: 0.1, radius: 1, xOffset: 0, yOffset: 2), show: true)
            .padding(.vertical, .padding8)
        }
        .trackErrorState(for: $vm.processingState)
        .hStateViewButtonConfig(
            .init(
                actionButton: .init(
                    buttonAction: {
                        vm.processingState = .success
                    }
                )
            )
        )
        .detent(
            presented: $showPaymentDetails,
            presentationStyle: .detent(style: [.large])
        ) {
            PaymentDetailsView(data: missedPaymentdata.paymentData, showsStatus: false)
                .withDismissButton()
                .embededInNavigation(tracking: missedPaymentdata.paymentData)
        }
        .disabled(vm.processingState == .loading)
        .modally(
            presented: $vm.showSuccessScreen
        ) {
            SuccessScreen(
                title: L10n.paymentsPaymentInProgress,
                subtitle: L10n.paymentsPaymentInProgressDescription,
                formPosition: .center
            )
            .hStateViewButtonConfig(
                .init(
                    actionButtonAttachedToBottom: .init(
                        buttonTitle: L10n.generalDoneButton,
                        buttonStyle: .secondary,
                        buttonAction: {
                            vm.showSuccessScreen = false
                        }
                    )
                )
            )
            .withDismissButton()
            .embededInNavigation(tracking: String(describing: SuccessScreen.self))
            .onAppear {
                router.popToRoot()
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
    }

    private var viewPaymentDetailsButton: some View {
        hButton(
            .medium,
            .ghost,
            content: .init(title: L10n.paymentsPaymentOverdueDetailsViewDetails),
            {
                showPaymentDetails = true
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
            if let account = missedPaymentdata.paymentChargeData.account {
                infoRow(
                    label: L10n.bankPayoutMethodCardTitle,
                    value: account
                )
            }
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
    }

    private var totalRow: some View {
        HStack {
            hText(L10n.PaymentDetails.ReceiptCard.total, style: .heading1)
                .foregroundColor(hTextColor.Opaque.primary)
            Spacer()
            hText(missedPaymentdata.paymentData.payment.net.formattedAmount, style: .heading1)
                .foregroundColor(hTextColor.Opaque.primary)
        }
    }

    private var payButton: some View {
        hButton(
            .medium,
            .primary,
            content: .init(
                title: L10n.paymentsPaymentOverdueDetailsPay(missedPaymentdata.paymentData.payment.net.formattedAmount)
            ),
            {
                vm.chargeOutstandingPayment()
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
                try await paymentService.chargeOutstandingPayment()
                processingState = .success
                showSuccessScreen = true
            } catch {
                processingState = .error(errorMessage: error.localizedDescription)
            }
        }
    }
}

#Preview {
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    let data = PaymentData(
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
        amountPerReferral: .sek(0),
        paymentChargeData: .init(
            paymentMethod: nil,
            bankName: nil,
            account: "*** *3242",
            mandate: nil,
            dueDate: 30,
            chargeMethod: .trustly
        ),
        addedToThePayment: nil
    )
    return MissedPaymentScreen(
        missedPaymentdata: .init(
            paymentData: data,
            paymentChargeData: data.paymentChargeData!
        )
    )
    .environmentObject(NavigationRouter())
}
