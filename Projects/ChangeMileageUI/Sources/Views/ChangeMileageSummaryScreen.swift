import ChangeMileageCore
import SwiftUI
import hCore
import hCoreUI

struct ChangeMileageSummaryScreen: View {
    let vm: ChangeMileageViewModel
    @Environment(ChangeMileageNavigationViewModel.self) var navigationVm

    var body: some View {
        hForm {
            hSection {
                summaryCard
            }
            .sectionContainerStyle(.transparent)
        }
        .hFormContentPosition(.top)
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: .padding16) {
                    hText(L10n.changeMileageSummaryFooter, style: .label)
                        .foregroundColor(hTextColor.Translucent.secondary)
                        .multilineTextAlignment(.center)
                    VStack(spacing: .padding8) {
                        hButton(.large, .primary, content: .init(title: L10n.confirmChangesTitle)) {
                            navigationVm.router.push(ChangeMileageRouterActionsWithoutBackButton.processing)
                            vm.commit()
                        }
                        hCancelButton {
                            navigationVm.router.dismiss()
                        }
                    }
                }
            }
            .sectionContainerStyle(.transparent)
        }
        .withAlertDismiss()
    }

    @ViewBuilder
    private var summaryCard: some View {
        if let quote = vm.selectedQuote {
            CardView {
                hRow {
                    ContractInformation(
                        title: vm.contract.displayName,
                        subtitle: L10n.changeAddressActivationDate(
                            vm.intent?.activationDate.displayDateDDMMMYYYYFormat ?? ""
                        ),
                        pillowImage: vm.contract.typeOfContract?.pillowType.bgImage
                    )
                }
                VStack(spacing: .padding4) {
                    ForEach(quote.displayItems, id: \.title) { item in
                        SummaryRow(title: item.title, previousValue: item.previousValue, value: item.value)
                    }
                }
                .padding(.horizontal, .padding16)
                .accessibilityElement(children: .combine)
                hRowDivider()
                    .padding(.vertical, .padding16)
                SummaryRow(
                    title: L10n.tierFlowTotal,
                    previousValue: previousTotal(for: quote),
                    value: quote.totalCost.net.formattedAmountPerMonth,
                    isTotal: true
                )
                .padding(.horizontal, .padding16)
                .padding(.bottom, .padding16)
            }
        }
    }

    private func previousTotal(for quote: MileageQuote) -> String? {
        guard let current = vm.intent?.currentTotalCost.net, current != quote.totalCost.net else { return nil }
        return current.formattedAmountPerMonth
    }
}

private struct SummaryRow: View {
    let title: String
    let previousValue: String?
    let value: String
    var isTotal = false

    var body: some View {
        HStack(alignment: .top) {
            hText(title, style: isTotal ? .body1 : .label)
                .foregroundColor(isTotal ? hTextColor.Opaque.primary : hTextColor.Translucent.secondary)
            Spacer()
            if let previousValue {
                hText(previousValue, style: isTotal ? .body1 : .label)
                    .foregroundColor(hTextColor.Translucent.secondary)
                    .strikethrough()
                    .accessibilityHidden(true)
            }
            hText(value, style: isTotal ? .body1 : .label)
                .foregroundColor(
                    isTotal || previousValue != nil ? hTextColor.Opaque.primary : hTextColor.Translucent.secondary
                )
        }
    }
}
