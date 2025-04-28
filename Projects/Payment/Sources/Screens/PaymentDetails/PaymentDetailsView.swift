import Campaign
import PresentableStore
import SwiftUI
import hCore
import hCoreUI

struct PaymentDetailsView: View {
    private let data: PaymentData
    @PresentableStore var store: PaymentStore
    @State var expandedContracts: [String] = []
    @EnvironmentObject var router: Router
    @Inject var featureFlags: FeatureFlags

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
        if !data.referralDiscounts.isEmpty {
            hSection(data.referralDiscounts, id: \.id) { referral in
                DiscountDetailView(vm: .init(options: [.forPayment], discount: referral))
                    .hWithoutHorizontalPadding([.row])
            }
            .withHeader(
                title: L10n.paymentsReferralsInfoTitle,
                infoButtonDescription: featureFlags.isRedeemCampaignDisabled
                    ? nil : L10n.paymentsDiscountInfoDescription,
                withoutBottomPadding: false
            )
            .sectionContainerStyle(.transparent)
            .hSectionHeaderWithDivider
            .hWithoutHorizontalPadding([.row, .divider])
            .padding(.top, .padding8)
        }
    }

    @ViewBuilder
    private var paymentDetailsSection: some View {
        hSection {
            carriedAdjustmentView
            settlementAdjustmentView
            total
            paymentDue
            bankDetails
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
                hText(data.payment.net.formattedAmount)
                hText(" ")
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
    private var bankDetails: some View {
        if let paymentDetails = data.paymentDetails {
            hSection(paymentDetails.getDisplayList, id: \.key) { item in
                hRow {
                    HStack {
                        hText(item.key)
                        Spacer()
                        hText(item.value)
                            .foregroundColor(hTextColor.Opaque.secondary)
                    }
                }
            }
            .hWithoutHorizontalPadding([.section, .row, .divider])
        }
    }
}

struct PaymentDetails_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale.send(.en_SE)
        Dependencies.shared.add(module: Module { () -> DateService in DateService() })
        Dependencies.shared.add(module: Module { () -> FeatureFlags in FeatureFlagsDemo() })
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
                    discounts: [
                        .init(
                            code: "TOGETHER",
                            amount: .init(amount: "10", currency: "SEK"),
                            title: "15% discount for 12 months",
                            listOfAffectedInsurances: [],
                            validUntil: nil,
                            canBeDeleted: true,
                            discountId: "id"
                        )
                    ],
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
                    ]
                ),
                .init(
                    id: "id2",
                    title: "title 2",
                    subtitle: "subtitle 2",
                    netAmount: .sek(350),
                    grossAmount: .sek(300),
                    discounts: [
                        .init(
                            code: "TOGETHER",
                            amount: .init(amount: "10", currency: "SEK"),
                            title: "15% discount for 12 months",
                            listOfAffectedInsurances: [],
                            validUntil: nil,
                            canBeDeleted: true,
                            discountId: "id"
                        )
                    ],
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
                    ]
                ),
            ],
            referralDiscounts: [
                .init(
                    code: "MY CODE",
                    amount: .sek(30),
                    title: "3 friends invited",
                    listOfAffectedInsurances: [],
                    validUntil: nil,
                    canBeDeleted: false,
                    discountId: "FRIENDS"
                )
            ],
            otherDiscounts: [
                .init(
                    code: "CODE",
                    amount: .sek(100),
                    title: "Title",
                    listOfAffectedInsurances: [
                        .init(id: "1", displayName: "Car 15%")
                    ],
                    validUntil: "2023-11-20",
                    canBeDeleted: false,
                    discountId: "CODE"
                ),
                .init(
                    code: "CODE2",
                    amount: .sek(99),
                    title: "Title1",
                    listOfAffectedInsurances: [
                        .init(id: "2", displayName: "House 15%")
                    ],
                    validUntil: "2023-11-22",
                    canBeDeleted: false,
                    discountId: "CODE2"
                ),
            ],
            paymentDetails: .init(paymentMethod: "bank", account: "account", bank: "bank"),
            addedToThePayment: nil
        )
        return PaymentDetailsView(data: data)
    }
}
