import SwiftUI
import hCore
import hCoreUI

struct EditDeductibleScreen: View {
    @State var selectedQuote: String?
    private let vm: ChangeTierViewModel
    private let quotes: [Quote]
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel

    init(
        vm: ChangeTierViewModel
    ) {
        self.vm = vm

        if !(vm.selectedTier?.quotes.isEmpty ?? true) {
            self.quotes = vm.selectedTier?.quotes ?? []
        } else {
            self.quotes = vm.tiers.first(where: { $0.name == vm.selectedTier?.name })?.quotes ?? []
        }

        self._selectedQuote = State(
            initialValue: vm.selectedQuote?.id ?? vm.selectedTier?.quotes.first?.id
        )
    }

    var body: some View {
        hForm {
            hSection {
                VStack(spacing: .padding4) {
                    ForEach(quotes.sorted(by: { $0.basePremium.value > $1.basePremium.value }), id: \.self) { quote in
                        hRadioField(
                            id: quote.id,
                            leftView: {
                                VStack(alignment: .leading, spacing: .padding8) {
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
                            },
                            selected: $selectedQuote,
                            error: nil,
                            useAnimation: true
                        )
                        .hFieldLeftAttachedView
                    }
                }
            }
            .padding(.top, 16)
            .sectionContainerStyle(.transparent)
        }
        .hFormContentPosition(.compact)
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: .padding8) {
                    hButton.LargeButton(type: .primary) {
                        vm.setDeductible(for: self.selectedQuote ?? "")
                        changeTierNavigationVm.isEditDeductiblePresented = false
                    } content: {
                        hText(L10n.generalConfirm)
                    }
                    .accessibilityHint(
                        L10n.voiceoverOptionSelected
                            + (self.quotes.first(where: { $0.id == selectedQuote })?.displayTitle ?? "")
                    )

                    hCancelButton {
                        changeTierNavigationVm.isEditDeductiblePresented = false
                    }
                }
            }
            .sectionContainerStyle(.transparent)
            .padding(.top, .padding16)
        }
        .configureTitleView(title: L10n.tierFlowSelectDeductibleTitle, subTitle: L10n.tierFlowSelectDeductibleSubtitle)
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> ChangeTierClient in ChangeTierClientOctopus() })
    let input = ChangeTierInput.contractWithSource(data: .init(source: .betterCoverage, contractId: "contractId"))
    return EditDeductibleScreen(vm: .init(changeTierInput: input))
}
