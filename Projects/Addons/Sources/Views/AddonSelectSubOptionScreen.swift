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

        if let selectedQuote = changeAddonNavigationVm.changeAddonVm?.selectedAddons.first ?? selectable.quotes.first {
            _selectedQuote = State(initialValue: selectedQuote)
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
                                changeAddonNavigationVm.changeAddonVm?.selectAddon(id: selected.id, addonType: .travel)
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

    @ViewBuilder
    private func leftView(for quote: AddonOfferQuote) -> some View {
        if let grossPriceDifference = changeAddonNavigationVm.changeAddonVm?
            .getGrossPriceDifference(for: quote)
        {
            HStack {
                hText(quote.displayTitle)
                Spacer()
                hPill(
                    text: L10n.addonFlowPriceLabel(grossPriceDifference.formattedAmount),
                    color: .grey,
                    colorLevel: .one
                )
                .hFieldSize(.small)
            }
        }
    }
}

#Preview {
    let offer = testTravelOfferNoActive

    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    Dependencies.shared.add(module: Module { () -> AddonsClient in AddonsClientDemo(offer: offer) })

    return AddonSelectSubOptionScreen(
        selectable: offer.quote.selectableOffer!,
        changeAddonNavigationVm: .init(
            input: .init(
                addonSource: .insurances,
                contractConfigs: [.init(contractId: "contractId", exposureName: "exposure", displayName: "displayName")]
            )
        )
    )
}
