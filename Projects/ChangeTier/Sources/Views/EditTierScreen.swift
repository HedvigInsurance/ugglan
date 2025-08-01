import SwiftUI
import hCore
import hCoreUI

struct EditTierScreen: View {
    @State var selectedTier: String?
    @ObservedObject var vm: ChangeTierViewModel
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel

    init(
        vm: ChangeTierViewModel
    ) {
        self.vm = vm
        _selectedTier = State(initialValue: vm.selectedTier?.name ?? vm.tiers.first?.name)
    }

    var body: some View {
        hForm {
            hSection {
                VStack(spacing: .padding4) {
                    ForEach(vm.tiers.sorted(by: { $0.level < $1.level }), id: \.self) { tier in
                        hRadioField(
                            id: tier.name,
                            leftView: {
                                VStack(alignment: .leading, spacing: 0) {
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
                            },
                            selected: $selectedTier,
                            error: nil,
                            useAnimation: true
                        )
                        .hFieldLeftAttachedView
                    }
                }
            }
            .padding(.top, .padding16)
            .sectionContainerStyle(.transparent)
            .hFieldSize(.medium)
        }
        .hFormContentPosition(.compact)
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: .padding8) {
                    hContinueButton {
                        vm.setTier(for: selectedTier ?? "")
                        changeTierNavigationVm.isEditTierPresented = false
                    }
                    .accessibilityHint(L10n.voiceoverOptionSelected + (selectedTier ?? ""))

                    hCancelButton {
                        changeTierNavigationVm.isEditTierPresented = false
                    }
                }
            }
            .sectionContainerStyle(.transparent)
            .padding(.top, .padding16)
        }
        .configureTitleView(title: L10n.tierFlowSelectCoverageTitle, subTitle: L10n.tierFlowSelectCoverageSubtitle)
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> ChangeTierClient in ChangeTierClientDemo() })
    let input = ChangeTierInput.contractWithSource(data: .init(source: .betterCoverage, contractId: "contractId"))
    return EditTierScreen(vm: .init(changeTierInput: input))
}
