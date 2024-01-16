import Presentation
import SwiftUI
import hCore
import hCoreUI

struct PaymentDetails: View {
    private let data: PaymentData
    @PresentableStore var store: PaymentStore
    @State var expandedContracts: [String] = []
    init(data: PaymentData) {
        self.data = data
    }

    var body: some View {
        hForm {
            VStack(spacing: 16) {
                contracts
                paymentInfo
                paymentInfoDetails
            }
            .padding(.vertical, 8)
        }
    }

    private var contracts: some View {
        VStack(spacing: 8) {
            ForEach(data.contracts) { contract in
                ContractDetails(expandedContracts: $expandedContracts, contract: contract)
            }
        }
    }

    @ViewBuilder
    private var paymentInfo: some View {
        if data.discounts.count > 0 {
            hSection(getPaymentElements(), id: \.id) { row in
                row.view
            }
            .withHeader {
                HStack {
                    hText(L10n.paymentsDiscountsSectionTitle)
                    Spacer()
                    InfoViewHolder(
                        title: L10n.paymentsDiscountInfoTitle,
                        description: L10n.paymentsDiscountInfoDescription
                    )
                }
                .padding(.bottom, -16)
            }
            .sectionContainerStyle(.transparent)
            .dividerInsets(.all, 0)

        } else {
            hSection(getPaymentElements(), id: \.id) { row in
                row.view
            }
            .sectionContainerStyle(.transparent)
            .dividerInsets(.all, 0)
        }

    }
    private func getPaymentElements() -> [(id: String, view: AnyView)] {
        var list: [(id: String, view: AnyView)] = []

        for discount in data.discounts {
            let view = AnyView(PaymentDetailsDiscountView(vm: .init(options: [.forPayment], discount: discount)))
            list.append(("\(discount.code)", view))

        }

        if let carriedAdjustment = data.payment.carriedAdjustment, carriedAdjustment.floatAmount > 0 {
            list.append(("carriedAdjusment", AnyView(carriedAdjustmentView)))
        }
        if let settlementAdjustment = data.payment.settlementAdjustment, settlementAdjustment.floatAmount > 0 {
            list.append(("settlementAdjustmentView", AnyView(settlementAdjustmentView)))
        }
        list.append(("total", AnyView(total)))
        list.append(("paymentDue", AnyView(paymentDue)))
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
            .hWithoutHorizontalPadding
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
            .hWithoutHorizontalPadding
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
                            .foregroundColor(hTextColor.secondary)
                            .strikethrough()
                    } else {
                        hText(data.payment.gross.formattedAmount)
                            .foregroundColor(hTextColor.secondary)
                    }
                }
                hText(data.payment.net.formattedAmount)
            }
        }
        .hWithoutHorizontalPadding
    }

    @ViewBuilder var paymentDue: some View {
        hRow {
            VStack(spacing: 16) {
                HStack {
                    hText(L10n.paymentsPaymentDue)
                    Spacer()
                    hText(data.payment.date.displayDate)
                        .foregroundColor(hTextColor.secondary)
                }
                if data.status != .upcoming {
                    PaymentStatusView(status: data.status) { action in
                        switch action {
                        case .viewAddedToPayment:
                            if let nextPayment = data.addedToThePayment?.first {
                                store.send(.navigation(to: .openPaymentDetails(data: nextPayment)))
                            }
                        }
                    }
                }
            }
            .hWithoutHorizontalPadding
        }
    }

    @ViewBuilder
    private var paymentInfoDetails: some View {
        if let paymentDetails = data.paymentDetails {
            hSection(getListForPaymentDetails(for: paymentDetails), id: \.id) { item in
                item.view
            }
            .sectionContainerStyle(.transparent)
        }
    }

    private func getListForPaymentDetails(
        for paymentDetails: PaymentData.PaymentDetails
    ) -> [(id: String, view: AnyView)] {
        var list: [(id: String, view: AnyView)] = []
        list.append(("header", AnyView(paymentDetailsHeaderView)))

        for item in paymentDetails.getDisplayList {
            let view = hRow {
                HStack {
                    hText(item.key)
                    Spacer()
                    hText(item.value)
                }
            }
            .hWithoutHorizontalPadding
            .dividerInsets(.all, 0)

            list.append((item.key, AnyView(view)))
        }
        return list
    }

    private var paymentDetailsHeaderView: some View {
        hRow {
            HStack {
                hText(L10n.PaymentDetails.NavigationBar.title)
                Spacer()
                InfoViewHolder(
                    title: L10n.paymentsPaymentDetailsInfoTitle,
                    description: L10n.paymentsPaymentDetailsInfoDescription
                )
                .foregroundColor(hTextColor.secondary)
            }
        }
        .hWithoutHorizontalPadding
    }
}

struct PaymentDetails_Previews: PreviewProvider {
    static var previews: some View {
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
                    amount: .sek(200),
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
                    amount: .sek(300),
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
            discounts: [
                .init(
                    id: "CODE",
                    code: "CODE",
                    amount: .sek(100),
                    title: "Title",
                    listOfAffectedInsurances: [
                        .init(id: "1", displayName: "Car 15%")
                    ],
                    validUntil: "2023-11-20",
                    canBeDeleted: false
                ),
                .init(
                    id: "CODE2",
                    code: "CODE2",
                    amount: .sek(99),
                    title: "Title1",
                    listOfAffectedInsurances: [
                        .init(id: "2", displayName: "House 15%")
                    ],
                    validUntil: "2023-11-22",
                    canBeDeleted: false
                ),
                .init(
                    id: "FRIENDS",
                    code: "MY CODE",
                    amount: .sek(30),
                    title: "3 friends invited",
                    listOfAffectedInsurances: [],
                    validUntil: nil,
                    canBeDeleted: false

                ),
            ],
            paymentDetails: nil,
            addedToThePayment: nil
        )
        return PaymentDetails(data: data)
    }
}

extension PaymentDetails {
    static func journey(with paymentData: PaymentData) -> some JourneyPresentation {
        HostingJourney(
            PaymentStore.self,
            rootView: PaymentDetails(data: paymentData)
        ) { action in
            if case let .navigation(navigateTo) = action {
                if case .goBack = navigateTo {
                    PopJourney()
                } else if case let .openPaymentDetails(data) = navigateTo {
                    PaymentDetails.journey(with: data)
                }
            }
        }
        .configureTitleView(paymentData)
    }
}
