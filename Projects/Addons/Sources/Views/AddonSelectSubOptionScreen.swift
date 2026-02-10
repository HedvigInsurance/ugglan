import SwiftUI
import hCore
import hCoreUI

struct AddonSelectSubOptionScreen: View {
    @ObservedObject var changeAddonNavigationVm: ChangeAddonNavigationViewModel
    let selectable: AddonOfferSelectable
    @State var selectedAddon: AddonOfferQuote?
    @EnvironmentObject var router: Router

    init(
        selectable: AddonOfferSelectable,
        changeAddonNavigationVm: ChangeAddonNavigationViewModel
    ) {
        self.selectable = selectable
        self.changeAddonNavigationVm = changeAddonNavigationVm
        let preselected = changeAddonNavigationVm.changeAddonVm?.selectedAddons.first ?? selectable.quotes.first
        _selectedAddon = State(initialValue: preselected)
    }

    var body: some View {
        hForm {
            VStack(spacing: .padding4) {
                ForEach(selectable.quotes) { quote in
                    hSection {
                        hRadioField(
                            id: quote,
                            itemModel: nil,
                            leftView: { leftView(for: quote).asAnyView },
                            selected: $selectedAddon,
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
                            if let selectedAddon {
                                changeAddonNavigationVm.changeAddonVm?.selectAddon(addon: selectedAddon)
                            }
                            router.dismiss()
                        }
                    )
                    .accessibilityHint(L10n.voiceoverOptionSelected + (selectedAddon?.displayTitle ?? ""))

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

    if case let .selectable(selectable) = offer.quote.addonOfferContent {
        return AddonSelectSubOptionScreen(
            selectable: selectable,
            changeAddonNavigationVm: .init(
                input: .init(
                    addonSource: .insurances,
                    contractConfigs: [
                        .init(contractId: "contractId", exposureName: "exposure", displayName: "displayName")
                    ]
                )
            )
        )
    }
    return EmptyView()
}
