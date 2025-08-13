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
                    if expandedContracts.contains(contract.id) {
                        hText(contract.title)
                            .multilineTextAlignment(.leading)
                    } else {
                        hText(contract.title)
                            .multilineTextAlignment(.leading)
                            .lineLimit(1)
                    }
                    Spacer()

                    HStack(spacing: .padding8) {
                        if contract.grossAmount != contract.netAmount {
                            if #available(iOS 16.0, *) {
                                hText(contract.grossAmount.formattedAmount)
                                    .strikethrough()
                                    .foregroundColor(hTextColor.Translucent.secondary)
                            } else {
                                hText(contract.grossAmount.formattedAmount)
                                    .foregroundColor(hTextColor.Translucent.secondary)
                            }
                        }

                        hText(contract.netAmount.formattedAmount)
                    }
                    .layoutPriority(1)
                    .layoutPriority(1)

                    hCoreUIAssets.chevronDown.view
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(hTextColor.Opaque.secondary)
                        .rotationEffect(
                            expandedContracts.contains(contract.id) ? Angle(degrees: -180) : Angle(degrees: 0)
                        )
                }
                if let subtitle = contract.subtitle, !subtitle.isEmpty {
                    hText(subtitle, style: .label)
                        .foregroundColor(hTextColor.Translucent.secondary)
                }
            }
            .lineLimit(expandedContracts.contains(contract.id) ? nil : 1)
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
            hSection(Array(contract.periods.enumerated()), id: \.element.id) { offset, period in
                hRow {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            hText(period.fromToDate)
                                .foregroundColor(
                                    getColor(hTextColor.Opaque.primary, isOutstanding: period.isOutstanding)
                                )
                            Spacer()
                            hText(period.amount.formattedAmount)
                                .foregroundColor(
                                    getColor(hTextColor.Opaque.primary, isOutstanding: period.isOutstanding)
                                )
                        }
                        if let desciption = period.desciption {
                            hText(desciption, style: .label)
                                .foregroundColor(
                                    getColor(hTextColor.Translucent.secondary, isOutstanding: period.isOutstanding)
                                )
                        }
                    }
                }
                .withEmptyAccessory
                .accessibilityElement(children: .combine)

                if contract.periods.count - 1 == offset {
                    if !contract.discounts.isEmpty {
                        ForEach(contract.discounts) { discount in
                            DiscountDetailView(vm: .init(options: [.forPayment], discount: discount))
                        }
                    }
                    hRow {
                        PriceField(
                            newPremium: contract.netAmount,
                            currentPremium: contract.grossAmount,
                            title: L10n.paymentsSubtotal
                        )
                        .hWithStrikeThroughPrice(setTo: .crossOldPrice)
                        .hPriceFormatting(setTo: .month)
                    }
                }
            }
            .hWithoutHorizontalPadding([.section])
            .transition(.opacity)
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
                        desciption: "description"
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
            )
        )
        Spacer()
    }
}
