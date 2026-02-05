import SwiftUI
import hCore
import hCoreUI

struct AddonSelectSubOptionScreen: View {
    @ObservedObject var changeAddonNavigationVm: ChangeAddonNavigationViewModel
    let selectable: AddonOfferSelectable
    @State var selectedQuote: AddonOfferQuote?
    @EnvironmentObject var router: Router

    init(
        selectable: AddonOfferSelectable,
        changeAddonNavigationVm: ChangeAddonNavigationViewModel
    ) {
        self.selectable = selectable
        self.changeAddonNavigationVm = changeAddonNavigationVm

        if let vm = changeAddonNavigationVm.changeAddonVm,
            let preSelected = vm.selectedQuote(for: selectable)
        {
            _selectedQuote = State(initialValue: preSelected)
        } else if let first = selectable.quotes.first {
            _selectedQuote = State(initialValue: first)
        }
    }

    var body: some View {
        hForm {
            VStack(spacing: .padding4) {
                ForEach(selectable.quotes) { quote in
                    hSection {
                        hRadioField(
                            id: quote,
                            itemModel: nil,
                            leftView: {
                                leftView(for: quote)
                                    .asAnyView
                            },
                            selected: $selectedQuote,
                            error: .constant(nil),
                            useAnimation: true
                        )
                        .hFieldSize(.medium)
                        .hFieldLeftAttachedView
                    }
                }
            }
            .padding(.top, .padding16)
        }
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: .padding8) {
                    hButton(
                        .large,
                        .primary,
                        content: .init(title: L10n.addonFlowSelectButton),
                        {
                            if let selected = selectedQuote {
                                changeAddonNavigationVm.changeAddonVm?.selectQuote(selected, for: selectable)
                            }
                            router.dismiss()
                        }
                    )
                    .accessibilityHint(L10n.voiceoverOptionSelected + (selectedQuote?.displayTitle ?? ""))

                    hCancelButton {
                        router.dismiss()
                    }
                }
            }
            .sectionContainerStyle(.transparent)
            .padding(.top, 16)
        }
        .hFormContentPosition(.compact)
        .configureTitleView(title: selectable.selectionTitle, subTitle: selectable.selectionDescription)
    }

    private func leftView(for quote: AddonOfferQuote) -> some View {
        HStack {
            hText(quote.displayTitle)
            Spacer()
            hPill(
                text: L10n.addonFlowPriceLabel(
                    changeAddonNavigationVm.changeAddonVm?
                        .getPriceForQuote(quote, in: selectable)?
                        .formattedAmount ?? ""
                ),
                color: .grey,
                colorLevel: .one
            )
            .hFieldSize(.small)
        }
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> AddonsClient in AddonsClientDemo() })

    let selectable = AddonOfferSelectable(
        fieldTitle: "Maximum travel days",
        selectionTitle: "Choose your coverage",
        selectionDescription: "Days covered when travelling",
        quotes: [
            AddonOfferQuote(
                id: "addon45",
                displayTitle: "45 days",
                displayDescription: "Coverage for trips up to 45 days",
                displayItems: [
                    .init(displayTitle: "Coverage", displayValue: "45 days"),
                    .init(displayTitle: "Insured people", displayValue: "You+1"),
                ],
                cost: .init(premium: .init(gross: .sek(99), net: .sek(49)), discounts: []),
                addonVariant: .init(
                    displayName: "Travel Plus 45",
                    documents: [],
                    perils: [],
                    product: "travel",
                    termsVersion: "1.0"
                )
            ),
            AddonOfferQuote(
                id: "addon60",
                displayTitle: "60 days",
                displayDescription: "Coverage for trips up to 60 days",
                displayItems: [
                    .init(displayTitle: "Coverage", displayValue: "60 days"),
                    .init(displayTitle: "Insured people", displayValue: "You+1"),
                ],
                cost: .init(premium: .init(gross: .sek(139), net: .sek(79)), discounts: []),
                addonVariant: .init(
                    displayName: "Travel Plus 60",
                    documents: [],
                    perils: [],
                    product: "travel",
                    termsVersion: "1.0"
                )
            ),
        ]
    )

    return AddonSelectSubOptionScreen(
        selectable: selectable,
        changeAddonNavigationVm: .init(
            input: .init(
                addonSource: .insurances,
                contractConfigs: [.init(contractId: "contractId", exposureName: "exposure", displayName: "displayName")]
            )
        )
    )
}
