import SwiftUI
import hCore
import hCoreUI

struct AddonSelectSubOptionScreen: View {
    @ObservedObject var changeAddonNavigationVm: ChangeAddonNavigationViewModel
    @ObservedObject private var changeAddonVm: ChangeAddonViewModel
    let addonOffer: AddonOffer

    init(
        addonOffer: AddonOffer,
        changeAddonNavigationVm: ChangeAddonNavigationViewModel
    ) {
        self.addonOffer = addonOffer
        self.changeAddonNavigationVm = changeAddonNavigationVm
        self.changeAddonVm = changeAddonNavigationVm.changeAddonVm!
        if changeAddonNavigationVm.changeAddonVm!.selectedQuote == nil {
            changeAddonNavigationVm.changeAddonVm!.selectedQuote = addonOffer.quotes.first

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
                                        text: L10n.addonFlowPriceLabel(quote.price?.formattedAmountWithoutSymbol ?? ""),
                                        color: .grey,
                                        colorLevel: .one
                                    )
                                    .hFieldSize(.small)
                                }
                                .asAnyView
                            },
                            selected: $changeAddonVm.selectedQuote,
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
        .hDisableScroll
        .hFormAttachToBottom {
            hSection {
                VStack(spacing: .padding8) {
                    hButton.LargeButton(type: .primary) {
                        changeAddonNavigationVm.isChangeCoverageDaysPresented = nil
                    } content: {
                        hText(L10n.addonFlowSelectButton)
                    }

                    hButton.LargeButton(type: .ghost) {
                        changeAddonNavigationVm.isChangeCoverageDaysPresented = nil
                    } content: {
                        hText(L10n.generalCancelButton)
                    }
                }
            }
            .sectionContainerStyle(.transparent)
            .padding(.top, 16)
        }
        .configureTitleView(self)
    }
}

extension AddonSelectSubOptionScreen: TitleView {
    func getTitleView() -> UIView {
        let view: UIView = UIHostingController(rootView: titleView).view
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        return view
    }

    @ViewBuilder
    private var titleView: some View {
        VStack(alignment: .leading, spacing: 0) {
            hText(L10n.addonFlowSelectSuboptionTitle, style: .heading1)
                .foregroundColor(hTextColor.Opaque.primary)
            hText(L10n.addonFlowSelectSuboptionSubtitle, style: .heading1)
                .foregroundColor(hTextColor.Opaque.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, .padding8)
    }
}

#Preview {
    let currentAddon: AddonQuote = .init(
        displayName: "45 days",
        quoteId: "quoteId45",
        addonId: "addonId45",
        displayItems: [
            .init(displayTitle: "Coverage", displayValue: "45 days"),
            .init(
                displayTitle: "Insured people",
                displayValue: "You+1"
            ),
        ],
        price: .init(amount: "49", currency: "SEK"),
        productVariant: .init(
            termsVersion: "",
            typeOfContract: "",
            partner: nil,
            perils: [],
            insurableLimits: [
                .init(label: "limit1", limit: "limit1", description: "description"),
                .init(label: "limit2", limit: "limit2", description: "description"),
                .init(label: "limit3", limit: "limit3", description: "description"),
                .init(label: "limit4", limit: "limit4", description: "description"),
            ],
            documents: [
                .init(displayName: "dodument1", url: "", type: .generalTerms),
                .init(displayName: "dodument2", url: "", type: .termsAndConditions),
                .init(displayName: "dodument3", url: "", type: .preSaleInfo),
            ],
            displayName: "display name",
            displayNameTier: nil,
            tierDescription: nil
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
                    displayItems: [
                        .init(displayTitle: "Coverage", displayValue: "45 days"),
                        .init(displayTitle: "Insured people", displayValue: "You+1"),
                    ],
                    price: .init(amount: "79", currency: "SEK"),
                    productVariant: .init(
                        termsVersion: "",
                        typeOfContract: "",
                        partner: nil,
                        perils: [],
                        insurableLimits: [
                            .init(label: "limit1", limit: "limit1", description: "description"),
                            .init(label: "limit2", limit: "limit2", description: "description"),
                            .init(label: "limit3", limit: "limit3", description: "description"),
                            .init(label: "limit4", limit: "limit4", description: "description"),
                        ],
                        documents: [
                            .init(displayName: "dodument1", url: "", type: .generalTerms),
                            .init(displayName: "dodument2", url: "", type: .termsAndConditions),
                            .init(displayName: "dodument3", url: "", type: .preSaleInfo),
                        ],
                        displayName: "display name",
                        displayNameTier: nil,
                        tierDescription: nil
                    )
                ),
            ]
        ),
        changeAddonNavigationVm: .init(
            input: .init()
        )
    )
}
