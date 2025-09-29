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
            _selectedQuote = State(initialValue: preSelectedQuote)
        } else if let firstQuote = addonOffer.quotes.first {
            _selectedQuote = State(initialValue: firstQuote)
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

    private func leftView(for quote: AddonQuote) -> some View {
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
    }
}

#Preview {
    let currentAddon: AddonQuote = .init(
        displayName: "45 days",
        displayNameLong: "Long display name",
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
        itemCost: .init(
            premium: .init(gross: .sek(99), net: .sek(49)),
            discounts: []
        ),
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
        ),
        documents: [
            .init(displayName: "dodument1", url: "www.hedvig.com", type: .unknown)
        ]
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
                    displayNameLong: "display name long",
                    quoteId: "quoteId60",
                    addonId: "addonId60",
                    addonSubtype: "addonId60",
                    displayItems: [
                        .init(displayTitle: "Coverage", displayValue: "45 days"),
                        .init(displayTitle: "Insured people", displayValue: "You+1"),
                    ],
                    itemCost: .init(
                        premium: .init(gross: .sek(139), net: .sek(79)),
                        discounts: []
                    ),
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
                    ),
                    documents: []
                ),
            ]
        ),
        changeAddonNavigationVm: .init(
            input: .init(addonSource: .insurances)
        )
    )
}
