import SwiftUI
import hCore
import hCoreUI

struct EditScreen: View {
    @State var selectedItem: String?
    private let vm: ChangeTierViewModel
    private let quotes: [Quote]
    private let type: EditTierType
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel

    init(
        vm: ChangeTierViewModel,
        type: EditTierType
    ) {
        self.vm = vm
        self.type = type

        if type == .deductible {
            _selectedItem = State(
                initialValue: vm.selectedQuote?.id ?? vm.selectedTier?.quotes.first?.id
            )
            if !(vm.selectedTier?.quotes.isEmpty ?? true) {
                quotes = vm.selectedTier?.quotes ?? []
            } else {
                quotes = vm.tiers.first(where: { $0.name == vm.selectedTier?.name })?.quotes ?? []
            }
        } else {
            _selectedItem = State(initialValue: vm.selectedTier?.name ?? vm.tiers.first?.name)
            quotes = []
        }
    }

    private var listToDisplayDeductible: [Quote] {
        quotes.sorted(by: { $0.basePremium.value > $1.basePremium.value })
    }

    private var listToDisplayTiers: [Tier] {
        vm.tiers.sorted(by: { $0.level < $1.level })
    }

    var body: some View {
        hForm {
            hSection {
                radioFields
            }
            .padding(.top, .padding16)
            .sectionContainerStyle(.transparent)
            .hFieldSize(.medium)
        }
        .hFormContentPosition(.compact)
        .hFormAttachToBottom {
            bottomView
        }
        .configureTitleView(
            title: type == .deductible ? L10n.tierFlowSelectDeductibleTitle : L10n.tierFlowSelectCoverageTitle,
            subTitle: type == .deductible ? L10n.tierFlowSelectDeductibleSubtitle : L10n.tierFlowSelectCoverageSubtitle
        )
    }

    @ViewBuilder
    private var radioFields: some View {
        VStack(spacing: .padding4) {
            if type == .deductible {
                ForEach(listToDisplayDeductible, id: \.self) { quote in
                    hRadioField(
                        id: quote.id,
                        leftView: { leftViewForQuote(quote) },
                        selected: $selectedItem,
                        error: nil,
                        useAnimation: true
                    )
                    .hFieldLeftAttachedView
                }
            } else {
                ForEach(listToDisplayTiers, id: \.self) { tier in
                    hRadioField(
                        id: tier.name,
                        leftView: { leftViewForTier(tier) },
                        selected: $selectedItem,
                        error: nil,
                        useAnimation: true
                    )
                    .hFieldLeftAttachedView
                }
            }
        }
    }

    private func leftViewForQuote(_ quote: Quote) -> AnyView {
        leftView(
            title: quote.displayTitle,
            premium: quote.basePremium.formattedAmountPerMonth,
            subTitle: quote.subTitle
        )
    }

    private func leftViewForTier(_ tier: Tier) -> AnyView {
        leftView(
            title: tier.quotes.first?.productVariant?.displayNameTier ?? tier.name,
            premium: tier.getPremiumLabel(),
            subTitle: tier.quotes.first?.productVariant?.tierDescription
        )
    }

    private func leftView(title: String, premium: String?, subTitle: String?) -> AnyView {
        VStack(alignment: .leading, spacing: .padding8) {
            HStack {
                hText(title)
                Spacer()
                if let premium {
                    hPill(
                        text: premium,
                        color: .grey,
                        colorLevel: .two
                    )
                    .hFieldSize(.small)
                }
            }
            if let subTitle, subTitle != "" {
                hText(subTitle, style: .label)
                    .foregroundColor(hTextColor.Translucent.secondary)
            }
        }
        .asAnyView
    }

    private var bottomView: some View {
        hSection {
            VStack(spacing: .padding8) {
                if type == .deductible {
                    hButton(
                        .large,
                        .primary,
                        content: .init(title: L10n.generalConfirm),
                        {
                            confirmDeductible()
                        }
                    )
                    .accessibilityHint(selectedQuoteAccessibilityHint)
                } else {
                    hContinueButton {
                        confirmTier()
                    }
                    .accessibilityHint(selectedTierAccessibilityHint)
                }

                hCancelButton {
                    cancelEditTier()
                }
            }
        }
        .sectionContainerStyle(.transparent)
        .padding(.top, .padding16)
    }

    private var selectedQuoteAccessibilityHint: String {
        let title = quotes.first(where: { $0.id == selectedItem })?.displayTitle ?? ""
        return L10n.voiceoverOptionSelected + title
    }

    private var selectedTierAccessibilityHint: String {
        L10n.voiceoverOptionSelected + (selectedItem ?? "")
    }

    private func confirmDeductible() {
        vm.setDeductible(for: selectedItem ?? "")
        changeTierNavigationVm.isEditTierPresented = nil
    }

    private func confirmTier() {
        vm.setTier(for: selectedItem ?? "")
        changeTierNavigationVm.isEditTierPresented = nil
    }

    private func cancelEditTier() {
        changeTierNavigationVm.isEditTierPresented = nil
    }
}

enum EditTierType {
    case tier
    case deductible
}

#Preview {
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> ChangeTierClient in ChangeTierClientDemo() })
    let input = ChangeTierInput.contractWithSource(data: .init(source: .betterCoverage, contractId: "contractId"))
    return EditScreen(
        vm: .init(changeTierInput: input),
        type: .deductible
    )
}

#Preview {
    Dependencies.shared.add(module: Module { () -> ChangeTierClient in ChangeTierClientDemo() })
    let input = ChangeTierInput.contractWithSource(data: .init(source: .betterCoverage, contractId: "contractId"))
    return EditScreen(
        vm: .init(changeTierInput: input),
        type: .tier
    )
}
