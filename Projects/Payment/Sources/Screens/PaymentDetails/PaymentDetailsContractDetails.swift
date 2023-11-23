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
                            Spacer()
                        }
                        hText(contract.amount.formattedAmount)
                        Image(uiImage: hCoreUIAssets.chevronDownSmall.image)
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(hTextColor.secondary)
                            .rotationEffect(
                                expandedContracts.contains(contract.id) ? Angle(degrees: -180) : Angle(degrees: 0)
                            )
                            .padding(.top, 4)
                    }
                    hText(contract.subtitle)
                        .foregroundColor(hTextColor.secondary)
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
                                .foregroundColor(getColor(hTextColor.primary, isOutstanding: period.isOutstanding))
                            Spacer()
                            hText(period.amount.formattedAmount)
                                .foregroundColor(getColor(hTextColor.secondary, isOutstanding: period.isOutstanding))

                        }
                        if let desciption = period.desciption {
                            hText(desciption, style: .standardSmall)
                                .foregroundColor(getColor(hTextColor.secondary, isOutstanding: period.isOutstanding))

                        }
                    }
                }
                .withEmptyAccessory
                if contract.periods.count - 1 == offset {
                    hRow {
                        hText(L10n.paymentsSubtotal)
                        Spacer()
                        hText(contract.amount.formattedAmount)
                    }
                }
            }
            .withoutHorizontalPadding
            .transition(.opacity)
        }
    }

    @hColorBuilder
    private func getColor(_ baseColor: some hColor, isOutstanding: Bool) -> some hColor {
        if isOutstanding {
            hSignalColor.redElement
        } else {
            baseColor
        }
    }
}
