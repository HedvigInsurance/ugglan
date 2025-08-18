import SwiftUI
import hCore
import hCoreUI

enum EditType {
    case tier
    case deductible
}

struct EditScreen: View {
    @State var selectedItem: String?
    private let vm: ChangeTierViewModel
    private let quotes: [Quote]
    private let type: EditType
    private let onCancel: () -> Void
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel

    init(
        vm: ChangeTierViewModel,
        type: EditType,
        onCancel: @escaping () -> Void
    ) {
        self.vm = vm
        self.type = type
        self.onCancel = onCancel

        if !(vm.selectedTier?.quotes.isEmpty ?? true) {
            quotes = vm.selectedTier?.quotes ?? []
        } else {
            quotes = vm.tiers.first(where: { $0.name == vm.selectedTier?.name })?.quotes ?? []
        }

        _selectedItem = State(
            initialValue: vm.selectedQuote?.id ?? vm.selectedTier?.quotes.first?.id
        )

        if type == .deductible {
        } else {
            _selectedItem = State(initialValue: vm.selectedTier?.name ?? vm.tiers.first?.name)
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
                VStack(spacing: .padding4) {

                    if type == .deductible {
                        ForEach(listToDisplayDeductible, id: \.self) { item in
                            hRadioField(
                                id: item.id,
                                leftView: { leftView(quote: item, tier: nil) },
                                selected: $selectedItem,
                                error: nil,
                                useAnimation: true
                            )
                            .hFieldLeftAttachedView
                        }
                    } else {
                        ForEach(listToDisplayTiers, id: \.self) { item in
                            hRadioField(
                                id: item.name,
                                leftView: { leftView(quote: nil, tier: item) },
                                selected: $selectedItem,
                                error: nil,
                                useAnimation: true
                            )
                            .hFieldLeftAttachedView
                        }
                    }
                }
            }
        }
        .hFormContentPosition(.compact)
        .hFormAttachToBottom {
            bottomView
        }
    }

    private func leftView(quote: Quote?, tier: Tier?) -> AnyView {
        if let quote {
            return VStack(alignment: .leading, spacing: .padding8) {
                HStack {
                    hText(quote.displayTitle)
                    Spacer()
                    hPill(
                        text: quote.basePremium.formattedAmountPerMonth,
                        color: .grey,
                        colorLevel: .two
                    )
                    .hFieldSize(.small)
                }
                if let subTitle = quote.subTitle, subTitle != "" {
                    hText(subTitle, style: .label)
                        .foregroundColor(hTextColor.Translucent.secondary)
                }
            }
            .asAnyView
        } else if let tier {
            return VStack(alignment: .leading, spacing: 0) {
                HStack {
                    hText(tier.quotes.first?.productVariant?.displayNameTier ?? tier.name)
                    Spacer()
                    if let premiumLabel = tier.getPremiumLabel() {
                        hPill(
                            text: premiumLabel,
                            color: .grey,
                            colorLevel: .two
                        )
                        .hFieldSize(.small)
                    }
                }
                if let subTitle = tier.quotes.first?.productVariant?.tierDescription {
                    hText(subTitle, style: .label)
                        .foregroundColor(hTextColor.Translucent.secondary)
                }
            }
            .asAnyView
        }
        return AnyView(EmptyView())
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
                            vm.setDeductible(for: selectedItem ?? "")
                            changeTierNavigationVm.isEditDeductiblePresented = false
                        }
                    )
                    .accessibilityHint(
                        L10n.voiceoverOptionSelected
                            + (quotes.first(where: { $0.id == selectedItem })?.displayTitle ?? "")
                    )
                } else {
                    hContinueButton {
                        vm.setTier(
                            for: selectedItem
                                ?? ""
                        )
                        changeTierNavigationVm.isEditTierPresented = false
                    }
                    .accessibilityHint(L10n.voiceoverOptionSelected + (selectedItem ?? ""))
                }

                hCancelButton {
                    onCancel()
                }
            }
        }
        .sectionContainerStyle(.transparent)
        .padding(.top, .padding16)
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> ChangeTierClient in ChangeTierClientDemo() })
    let input = ChangeTierInput.contractWithSource(data: .init(source: .betterCoverage, contractId: "contractId"))
    return EditScreen(
        vm: .init(changeTierInput: input),
        type: .deductible,
        onCancel: {}
    )
}
