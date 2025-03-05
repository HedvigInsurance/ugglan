import SwiftUI
import hCore
import hCoreUI

struct ContractDetails: View {
    @Binding var expandedContracts: [String]
    let contract: PaymentData.ContractPaymentDetails

    var body: some View {
        hSection {
            hRow {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top, spacing: 8) {
                        HStack {
                            hText(contract.title)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                        }
                        hText(contract.amount.formattedAmount)
                        Image(uiImage: hCoreUIAssets.chevronDownSmall.image)
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(hTextColor.Opaque.secondary)
                            .rotationEffect(
                                expandedContracts.contains(contract.id) ? Angle(degrees: -180) : Angle(degrees: 0)
                            )
                            .padding(.top, .padding4)
                    }
                    if let subtitle = contract.subtitle, !subtitle.isEmpty {
                        hText(subtitle)
                            .foregroundColor(hTextColor.Opaque.secondary)
                    }
                }
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
            getContractDetails(for: contract)
        }
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
                                    getColor(hTextColor.Opaque.secondary, isOutstanding: period.isOutstanding)
                                )

                        }
                        if let desciption = period.desciption {
                            hText(desciption, style: .label)
                                .foregroundColor(
                                    getColor(hTextColor.Opaque.secondary, isOutstanding: period.isOutstanding)
                                )

                        }
                    }
                }
                .withEmptyAccessory
                .accessibilityElement(children: .combine)
                if contract.periods.count - 1 == offset {
                    hRow {
                        hText(L10n.paymentsSubtotal)
                        Spacer()
                        hText(contract.amount.formattedAmount)
                        hText(" ")
                    }
                    .accessibilityElement(children: .combine)
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

#Preview {
    @State var isExpanded: [String] = ["id1"]
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })

    return ContractDetails(
        expandedContracts: $isExpanded,
        contract: .init(
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
        )
    )
}
