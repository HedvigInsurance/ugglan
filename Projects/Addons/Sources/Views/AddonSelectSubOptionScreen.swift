import SwiftUI
import hCore
import hCoreUI

struct AddonSelectSubOptionScreen: View {
    @ObservedObject var changeAddonNavigationVm: ChangeAddonNavigationViewModel
    let addonOffer: AddonOffer
    @State var selectedQuote: AddonQuote?
    @EnvironmentObject var router: Router

    init(
        addonOffer: AddonOffer,
        changeAddonNavigationVm: ChangeAddonNavigationViewModel
    ) {
        self.addonOffer = addonOffer
        self.changeAddonNavigationVm = changeAddonNavigationVm

        if let preSelectedQuote = changeAddonNavigationVm.changeAddonVm!.selectedQuote {
            self._selectedQuote = State(initialValue: preSelectedQuote)
        } else if let firstQuote = addonOffer.quotes.first {
            self._selectedQuote = State(initialValue: firstQuote)
        }
    }

    var body: some View {
        hForm {
            VStack(spacing: .padding4) {
                ForEach(addonOffer.quotes, id: \.self) { quote in
                    hSection {
                        hRadioField(
                            id: quote,
                            itemModel: nil,
                            leftView: {
                                HStack {
                                    hText(quote.displayName ?? "")
                                    Spacer()
                                    hPill(
                                        text: L10n.addonFlowPriceLabel(
                                            addonOffer
                                                .getTotalPrice(selectedQuote: quote)?
                                                .formattedAmount ?? ""
                                        ),
                                        color: .grey,
                                        colorLevel: .one
                                    )
                                    .hFieldSize(.small)
                                }
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
                            changeAddonNavigationVm.changeAddonVm?.selectedQuote = selectedQuote
                            router.dismiss()
                        }
                    )
                    .accessibilityHint(L10n.voiceoverOptionSelected + (selectedQuote?.displayName ?? ""))

                    hCancelButton {
                        router.dismiss()
                    }
                }
            }
            .sectionContainerStyle(.transparent)
            .padding(.top, 16)
        }
        .hFormContentPosition(.compact)
        .configureTitleView(title: L10n.addonFlowSelectSuboptionTitle, subTitle: L10n.addonFlowSelectSuboptionSubtitle)
    }
}

#Preview {
    let currentAddon: AddonQuote = .init(
        displayName: "45 days",
        quoteId: "quoteId45",
        addonId: "addonId45",
        addonSubtype: "addonId45",
        displayItems: [
            .init(displayTitle: "Coverage", displayValue: "45 days"),
            .init(
                displayTitle: "Insured people",
                displayValue: "You+1"
            ),
        ],
        price: .init(amount: "49", currency: "SEK"),
        addonVariant: .init(
            displayName: "display name",
            documents: [
                .init(displayName: "dodument1", url: "", type: .generalTerms),
                .init(displayName: "dodument2", url: "", type: .termsAndConditions),
                .init(displayName: "dodument3", url: "", type: .preSaleInfo),
            ],
            perils: [],
            product: "",
            termsVersion: ""
        )
    )

    AddonSelectSubOptionScreen(
        addonOffer: .init(
            titleDisplayName: "Travel Plus",
            description: "Extended travel insurance with extra coverage for your travels",
            activationDate: "2025-01-15".localDateToDate,
            currentAddon: currentAddon,
            quotes: [
                currentAddon,
                .init(
                    displayName: "60 days",
                    quoteId: "quoteId60",
                    addonId: "addonId60",
                    addonSubtype: "addonId60",
                    displayItems: [
                        .init(displayTitle: "Coverage", displayValue: "45 days"),
                        .init(displayTitle: "Insured people", displayValue: "You+1"),
                    ],
                    price: .init(amount: "79", currency: "SEK"),
                    addonVariant: .init(
                        displayName: "display name",
                        documents: [
                            .init(displayName: "dodument1", url: "", type: .generalTerms),
                            .init(displayName: "dodument2", url: "", type: .termsAndConditions),
                            .init(displayName: "dodument3", url: "", type: .preSaleInfo),
                        ],
                        perils: [],
                        product: "",
                        termsVersion: ""
                    )
                ),
            ]
        ),
        changeAddonNavigationVm: .init(
            input: .init(addonSource: .insurances)
        )
    )
}
