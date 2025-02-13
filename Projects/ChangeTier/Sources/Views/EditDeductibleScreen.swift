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

                    hButton.LargeButton(type: .ghost) {
                        changeTierNavigationVm.isEditDeductiblePresented = false
                    } content: {
                        hText(L10n.generalCancelButton)
                    }

                }
            }
            .sectionContainerStyle(.transparent)
            .padding(.top, .padding16)
        }
        .configureTitleView(self)
    }
}

extension EditDeductibleScreen: TitleView {
    public func getTitleView() -> UIView {
        let view: UIView = UIHostingController(rootView: titleView).view
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }

    @ViewBuilder
    private var titleView: some View {
        VStack(alignment: .leading, spacing: 0) {
            hText(L10n.tierFlowSelectDeductibleTitle, style: .heading1)
                .foregroundColor(hTextColor.Opaque.primary)
            hText(L10n.tierFlowSelectDeductibleSubtitle, style: .heading1)
                .foregroundColor(hTextColor.Translucent.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, .padding8)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> ChangeTierClient in ChangeTierClientOctopus() })
    let input = ChangeTierInput.contractWithSource(data: .init(source: .betterCoverage, contractId: "contractId"))
    return EditDeductibleScreen(vm: .init(changeTierInput: input))
}
