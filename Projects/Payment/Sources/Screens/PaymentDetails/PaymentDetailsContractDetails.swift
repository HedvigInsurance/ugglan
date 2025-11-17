import Campaign
import SwiftUI
import hCore
import hCoreUI

struct ContractDetails: View {
    @Binding var expandedContracts: [String]
    let contract: PaymentData.ContractPaymentDetails

    var body: some View {
        hSection {
            insuranceSection
            getContractDetails(for: contract)
        }
    }

    private var insuranceSection: some View {
        hRow {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: .padding8) {
                    hText(contract.title)
                        .multilineTextAlignment(.leading)
                    Spacer()

                    hText(contract.netAmount.formattedAmount)
                        .layoutPriority(1)

                    hCoreUIAssets.chevronDown.view
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(hTextColor.Translucent.secondary)
                        .rotationEffect(
                            expandedContracts.contains(contract.id) ? Angle(degrees: -180) : Angle(degrees: 0)
                        )
                }
                if let subtitle = contract.subtitle, !subtitle.isEmpty {
                    hText(subtitle, style: .label)
                        .foregroundColor(hTextColor.Translucent.secondary)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .withEmptyAccessory
        .onTap {
            withAnimation {
                if let index = expandedContracts.firstIndex(of: contract.id) {
                    expandedContracts.remove(at: index)
                } else {
                    expandedContracts.append(contract.id)
                }
            }
        }
        .hWithoutDivider
    }

    @ViewBuilder
    func getContractDetails(for contract: PaymentData.ContractPaymentDetails) -> some View {
        if expandedContracts.contains(contract.id) {
            hRowDivider()
            hRow {
                VStack(spacing: .padding6) {
                    ForEach(contract.priceBreakdown) { item in
                        PriceBreakdowRowItem(title: item.displayTitle, value: item.amount.priceFormat(.month))
                    }
                    PriceField(
                        viewModel: .init(
                            initialValue: contract.grossAmount,
                            newValue: contract.netAmount,
                            title: L10n.paymentsSubtotal,
                            useSecondaryColor: true
                        )
                    )
                    .hWithStrikeThroughPrice(setTo: .crossOldPrice)
                    .hPriceFormatting(setTo: .month)
                    .hTextStyle(.label)
                }
                .foregroundColor(hTextColor.Translucent.secondary)
            }
            hSection {
                VStack(alignment: .leading, spacing: .padding16) {
                    ForEach(contract.periods) { period in
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                hText(period.fromToDate)
                                    .foregroundColor(
                                        hTextColor.Translucent.secondary
                                    )
                                Spacer()
                                hText(period.amount.formattedAmount)
                                    .foregroundColor(
                                        hTextColor.Translucent.secondary
                                    )
                            }
                            if let desciption = period.desciption {
                                hText(desciption)
                                    .foregroundColor(
                                        getColor(hTextColor.Translucent.secondary, isOutstanding: period.isOutstanding)
                                    )
                            }
                        }
                        .accessibilityElement(children: .combine)
                        .hTextStyle(.label)
                    }
                    PriceField(
                        viewModel: .init(
                            initialValue: nil,
                            newValue: contract.netAmount,
                            title: L10n.paymentsAmountToPay
                        )
                    )
                    .hWithStrikeThroughPrice(setTo: .crossOldPrice)
                    .hPriceFormatting(setTo: .month)
                }
                .padding(.bottom, .padding16)
            }
            .withHeader(title: "Period")
        }
    }

    @hColorBuilder
    private func getColor(_ baseColor: some hColor, isOutstanding: Bool) -> some hColor {
        if isOutstanding {
            hSignalColor.Red.element
        } else {
            baseColor
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State var isExpanded = ["id1"]
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })

    return VStack {
        ContractDetails(
            expandedContracts: $isExpanded,
            contract: .init(
                id: "id1",
                title: "title long title thatgoes 2 lines",
                subtitle: "subtitle which is long so it takes 2 so we can see how it looks",
                netAmount: .sek(250),
                grossAmount: .sek(200),
                periods: [
                    .init(
                        id: "1",
                        from: "2023-11-10",
                        to: "2023-11-23",
                        amount: .sek(100),
                        isOutstanding: false,
                        desciption: "description"
                    ),
                    .init(
                        id: "2",
                        from: "2023-11-23",
                        to: "2023-11-30",
                        amount: .sek(80),
                        isOutstanding: true,
                        desciption: "description"
                    ),
                ],
                priceBreakdown: [
                    .init(displayTitle: "Contract", amount: MonetaryAmount.sek(10)),
                    .init(displayTitle: "15% discount for 12 months", amount: MonetaryAmount.sek(10)),
                ]
            )
        )
        Spacer()
    }
}
