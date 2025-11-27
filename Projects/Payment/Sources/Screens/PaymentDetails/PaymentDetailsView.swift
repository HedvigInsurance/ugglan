import Campaign
import SwiftUI
import hCore
import hCoreUI

struct PaymentDetailsView: View {
    private let data: PaymentData
    @State var expandedContracts: [String] = []
    @EnvironmentObject var router: Router

    init(data: PaymentData) {
        self.data = data
    }

    var body: some View {
        hForm {
            VStack(spacing: .padding16) {
                contractsSection
                referralSection
                paymentDetailsSection
            }
            .padding(.vertical, .padding8)
        }
    }

    private var contractsSection: some View {
        VStack(spacing: .padding8) {
            ForEach(data.contracts) { contract in
                ContractDetails(expandedContracts: $expandedContracts, contract: contract)
            }
        }
    }

    @ViewBuilder
    private var referralSection: some View {
        if let referralDiscount = data.referralDiscount {
            hSection {
                DiscountDetailView(discount: referralDiscount)
                    .hWithoutHorizontalPadding([.row])
            }
            .withHeader(
                title: L10n.ReferralsInfoSheet.headline,
                infoButtonDescription: L10n.ReferralsInfoSheet.body(
                    data.amountPerReferral.formattedAmount,
                )
            )

            .sectionContainerStyle(.transparent)
            .hSectionHeaderWithDivider
            .hWithoutHorizontalPadding([.row, .divider])
            .padding(.top, .padding8)
        }
    }

    @ViewBuilder
    private var paymentDetailsSection: some View {
        hSection(paymentViewItems, id: \.id) { view in
            view.view
        }
        .withHeader(
            title: L10n.PaymentDetails.NavigationBar.title,
            infoButtonDescription: L10n.paymentsPaymentDetailsInfoDescription,
            withoutBottomPadding: false
        )
        .sectionContainerStyle(.transparent)
        .hSectionHeaderWithDivider
        .hWithoutHorizontalPadding([.row, .divider])
    }

    private var paymentViewItems: [(id: String, view: AnyView)] {
        var list: [(id: String, view: AnyView)] = []

        list.append(("carriedAdjustment", AnyView(carriedAdjustmentView)))
        list.append(("settlementAdjustment", AnyView(settlementAdjustmentView)))
        list.append(("total", AnyView(total)))
        list.append(("paymentDue", AnyView(paymentDue)))
        if let paymentDetails = data.paymentChargeData {
            list.append(("bankDetails", AnyView(bankDetails(data: paymentDetails))))
        }
        return list
    }

    @ViewBuilder
    private var carriedAdjustmentView: some View {
        if let carriedAdjustment = data.payment.carriedAdjustment, carriedAdjustment.floatAmount > 0 {
            hRow {
                VStack {
                    HStack {
                        hText(L10n.paymentsCarriedAdjustment)
                        Spacer()
                        hText(carriedAdjustment.formattedAmount)
                    }
                    InfoCard(text: L10n.paymentsCarriedAdjustmentInfo, type: .info)
                }
            }
        }
    }

    @ViewBuilder
    private var settlementAdjustmentView: some View {
        if let settlementAdjustment = data.payment.settlementAdjustment, settlementAdjustment.floatAmount > 0 {
            hRow {
                VStack {
                    HStack {
                        hText(L10n.paymentsSettlementAdjustment)
                        Spacer()
                        hText(settlementAdjustment.formattedAmount)
                    }
                    InfoCard(text: L10n.paymentsSettlementAdjustmentInfo, type: .info)
                }
            }
        }
    }

    @ViewBuilder
    private var total: some View {
        hRow {
            hText(L10n.PaymentDetails.ReceiptCard.total)
        }
        .withCustomAccessory {
            HStack {
                Spacer()
                if data.payment.gross.amount != data.payment.net.amount {
                    if #available(iOS 16.0, *) {
                        hText(data.payment.gross.formattedAmount)
                            .foregroundColor(hTextColor.Opaque.secondary)
                            .strikethrough()
                    } else {
                        hText(data.payment.gross.formattedAmount)
                            .foregroundColor(hTextColor.Opaque.secondary)
                    }
                }
                ZStack {
                    hText(data.payment.net.formattedAmount)
                    hText(" ")
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder var paymentDue: some View {
        hRow {
            VStack(spacing: .padding16) {
                HStack {
                    hText(L10n.paymentsPaymentDue)
                    Spacer()
                    hText(data.payment.date.displayDate)
                        .foregroundColor(hTextColor.Opaque.secondary)
                }
                if data.status != .upcoming {
                    PaymentStatusView(status: data.status) { action in
                        switch action {
                        case .viewAddedToPayment:
                            if let nextPayment = data.addedToThePayment?.first {
                                router.push(nextPayment)
                            }
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func bankDetails(data: PaymentChargeData) -> some View {
        PaymentMethodView(data: data, withDate: false)
            .hWithoutHorizontalPadding([.section, .row, .divider])
    }
}

#Preview {
    Localization.Locale.currentLocale.send(.en_SE)
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> FeatureFlagsClient in FeatureFlagsDemo() })
    let data = PaymentData(
        id: "id",
        payment: .init(
            gross: .sek(200),
            net: .sek(180),
            carriedAdjustment: .sek(100),
            settlementAdjustment: .sek(20),
            date: "2022-10-30"
        ),
        status: .upcoming,
        contracts: [
            .init(
                id: "id1",
                title: "title",
                subtitle: "subtitle",
                netAmount: .sek(250),
                grossAmount: .sek(200),
                periods: [
                    .init(
                        id: "1",
                        from: "2023-11-10",
                        to: "2023-11-23",
                        amount: .sek(100),
                        isOutstanding: false,
                        desciption: nil
                    ),
                    .init(
                        id: "2",
                        from: "2023-11-23",
                        to: "2023-11-30",
                        amount: .sek(80),
                        isOutstanding: true,
                        desciption: nil
                    ),
                ],
                priceBreakdown: [
                    .init(displayTitle: "15% discount for 12 months", amount: MonetaryAmount.sek(10))
                ]
            ),
            .init(
                id: "id2",
                title: "title 2",
                subtitle: "subtitle 2",
                netAmount: .sek(350),
                grossAmount: .sek(300),
                periods: [
                    .init(
                        id: "1",
                        from: "2023-11-10",
                        to: "2023-11-23",
                        amount: .sek(100),
                        isOutstanding: false,
                        desciption: nil
                    ),
                    .init(
                        id: "2",
                        from: "2023-11-23",
                        to: "2023-11-30",
                        amount: .sek(80),
                        isOutstanding: true,
                        desciption: nil
                    ),
                ],
                priceBreakdown: [
                    .init(displayTitle: "15% discount for 12 months", amount: MonetaryAmount.sek(10))
                ]
            ),
        ],
        referralDiscount:
            .init(
                code: "MY CODE",
                displayValue: MonetaryAmount.sek(10).formattedNegativeAmount,
                description: "3 friends invited",
                type: .referral
            ),
        amountPerReferral: .sek(10),
        paymentChargeData: .init(
            paymentMethod: "bank",
            bankName: "bank",
            account: "account",
            mandate: "mandate",
            chargingDayInTheMonth: 20
        ),
        addedToThePayment: nil
    )
    return PaymentDetailsView(data: data)
}
