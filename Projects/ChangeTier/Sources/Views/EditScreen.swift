import Addons
import SwiftUI
import hCore
import hCoreUI

struct EditScreen: View {
    @State var selectedItem: String?
    private let vm: ChangeTierViewModel
    private let type: EditTierType
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel

    init(
        selectedItem: String?,
        vm: ChangeTierViewModel,
        type: EditTierType
    ) {
        self.vm = vm
        self.type = type
        _selectedItem = State(initialValue: selectedItem)
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
            title: type.title,
            subTitle: type.subTitle
        )
    }

    @ViewBuilder
    private var radioFields: some View {
        VStack(spacing: .padding4) {
            switch type {
            case let .tiers(tiers):
                ForEach(tiers, id: \.self) { tier in
                    hRadioField(
                        id: tier.name,
                        leftView: { leftViewForTier(tier) },
                        selected: $selectedItem,
                        error: nil,
                        useAnimation: true
                    )
                    .hFieldLeftAttachedView
                }
            case let .deductible(quotes):
                ForEach(quotes, id: \.self) { quote in
                    hRadioField(
                        id: quote.id,
                        leftView: { leftViewForQuote(quote) },
                        selected: $selectedItem,
                        error: nil,
                        useAnimation: true
                    )
                    .hFieldLeftAttachedView
                }
            case let .addon(addon):
                hRadioField(
                    id: addon.displayName ?? "",
                    leftView: { leftViewForAddon(addon) },
                    selected: $selectedItem,
                    error: nil,
                    useAnimation: true
                )
                .hFieldLeftAttachedView
                hRadioField(
                    id: L10n.tierFlowAddonNoCoverageLabel,
                    leftView: {
                        leftView(
                            title: L10n.tierFlowAddonNoCoverageLabel,
                            premium: MonetaryAmount(amount: "0", currency: "sek").formattedAmountPerMonth,
                            subTitle: nil
                        )
                    },
                    selected: $selectedItem,
                    error: nil,
                    useAnimation: true
                )
                .hFieldLeftAttachedView
            }
        }
    }

    private func leftViewForQuote(_ quote: Quote) -> AnyView {
        leftView(
            title: quote.displayTitle,
            premium: quote.newTotalCost.net?.formattedAmountPerMonth,
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

    private func leftViewForAddon(_ addon: AddonQuote) -> AnyView {
        leftView(
            title: addon.displayName ?? "",
            premium: addon.itemCost.premium.gross?.formattedAmountPerMonth,
            subTitle: nil
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
                Group {
                    switch type {
                    case .tiers:
                        hContinueButton {
                            confirm()
                        }
                    case .deductible:
                        hButton(
                            .large,
                            .primary,
                            content: .init(title: L10n.generalConfirm),
                            {
                                confirm()
                            }
                        )
                    case .addon:
                        hContinueButton {
                            confirm()
                        }
                    }
                }
                .accessibilityHint(hint)

                hCancelButton {
                    dismissEdit()
                }
            }
        }
        .sectionContainerStyle(.transparent)
        .padding(.top, .padding16)
    }

    private var hint: String {
        switch type {
        case .tiers, .addon:
            return L10n.voiceoverOptionSelected + (selectedItem ?? "")
        case let .deductible(quotes):
            let title = quotes.first(where: { $0.id == selectedItem })?.displayTitle ?? ""
            return L10n.voiceoverOptionSelected + title
        }
    }

    private func confirm() {
        switch type {
        case .tiers(let tiers):
            vm.setTier(for: selectedItem ?? "")
        case .deductible(let quotes):
            vm.setDeductible(for: selectedItem ?? "")
        case .addon(let addon):
            vm.setAddonStatus(for: addon.addonSubtype, enabled: selectedItem == addon.displayName)
        }
        changeTierNavigationVm.isEditTierPresented = nil
    }
    private func dismissEdit() {
        changeTierNavigationVm.isEditTierPresented = nil
    }
}

enum EditTierType: Equatable {
    case tiers(tiers: [Tier])
    case deductible(quotes: [Quote])
    case addon(addon: AddonQuote)

    var title: String {
        switch self {
        case .tiers: return L10n.tierFlowSelectCoverageTitle
        case .deductible: return L10n.tierFlowSelectDeductibleTitle
        case let .addon(addon): return addon.addonSubtype
        }
    }

    var subTitle: String {
        switch self {
        case .tiers: return L10n.tierFlowSelectCoverageSubtitle
        case .deductible: return L10n.tierFlowSelectDeductibleSubtitle
        case .addon: return L10n.tierFlowSelectAddonSubtitle
        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> ChangeTierClient in ChangeTierClientDemo() })
    let input = ChangeTierInput.contractWithSource(data: .init(source: .betterCoverage, contractId: "contractId"))
    return EditScreen(
        selectedItem: "String",
        vm: .init(
            changeTierInput: input
        ),
        type: .deductible(quotes: [])
    )
}

#Preview {
    Dependencies.shared.add(module: Module { () -> ChangeTierClient in ChangeTierClientDemo() })
    let input = ChangeTierInput.contractWithSource(data: .init(source: .betterCoverage, contractId: "contractId"))
    return EditScreen(
        selectedItem: "",
        vm: .init(
            changeTierInput: input
        ),
        type: .tiers(tiers: [])
    )
}
