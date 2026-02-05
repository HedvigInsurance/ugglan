import SwiftUI
import hCore
import hCoreUI

struct ChangeAddonScreen: View {
    @EnvironmentObject var changeAddonNavigationVm: ChangeAddonNavigationViewModel
    @ObservedObject var changeAddonVm: ChangeAddonViewModel

    init(
        changeAddonVm: ChangeAddonViewModel
    ) {
        self.changeAddonVm = changeAddonVm
    }

    var body: some View {
        successView.loading($changeAddonVm.fetchAddonsViewState)
            .hStateViewButtonConfig(
                .init(
                    actionButton: .init(
                        buttonAction: {
                            Task {
                                await changeAddonVm.getAddons()
                            }
                        }
                    ),
                    dismissButton:
                        .init(
                            buttonAction: {
                                changeAddonNavigationVm.router.dismiss()
                            }
                        )
                )
            )
    }

    private var successView: some View {
        hForm {}
            .hFormTitle(
                title: .init(
                    .small,
                    .body2,
                    changeAddonVm.addonOffer?.pageTitle ?? "",
                    alignment: .leading
                ),
                subTitle: .init(
                    .small,
                    .body2,
                    changeAddonVm.addonOffer?.pageDescription ?? ""
                )
            )
            .hFormAttachToBottom {
                CardView {
                    hRow {
                        addOnSection
                    }
                    hRow {
                        coverageButtonView
                    }
                    .verticalPadding(0)
                    .padding(.bottom, .padding16)
                }

                hSection {
                    hContinueButton {
                        changeAddonNavigationVm.router.push(ChangeAddonRouterActions.summary)
                    }
                    .disabled(!changeAddonVm.allowToContinue)
                }
                .sectionContainerStyle(.transparent)
            }
    }

    @ViewBuilder
    private var addOnSection: some View {
        if let offer = changeAddonVm.addonOffer {
            VStack(alignment: .leading, spacing: 0) {
                let displayPriceDiff = !changeAddonVm.selectedAddonIds.isEmpty
                HStack {
                    hText(offer.pageTitle)
                    Spacer()
                    hPill(
                        text: L10n.addonFlowPriceLabel(
                            changeAddonVm.getPriceIncrease().gross!.formattedAmount
                        ),
                        color: .grey,
                        colorLevel: .one
                    )
                    .hFieldSize(.small)
                    .opacity(displayPriceDiff ? 1.0 : 0.0)
                }

                hText(offer.pageDescription, style: .label)
                    .foregroundColor(hTextColor.Translucent.secondary)
                    .padding(.top, .padding8)

                switch (offer.addonType) {
                case .travel: travelAddonSection(travelOffer: offer)
                case .car: carAddonSection(carOffer: offer)
                }
            }
        }
    }

    @ViewBuilder
    private func carAddonSection(carOffer: AddonOfferV2) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(carOffer.activeAddons) { activeAddon in
                addonToggleRow(
                    title: activeAddon.displayTitle,
                    subtitle: activeAddon.displayDescription ?? "",
                    isSelected: true,
                    isDisabled: true,
                    trailingView: {
                        hPill(text: L10n.addonBadgeActive, color: .green)
                            .hFieldSize(.small)
                    }
                )
                .padding(.top, .padding16)
            }

            ForEach(carOffer.allAddons) { addonQuote in
                addonToggleRow(
                    title: addonQuote.displayTitle,
                    subtitle: addonQuote.displayDescription,
                    isSelected: changeAddonVm.isAddonSelected(addonQuote),
                    trailingView: {
                        hPill(
                            text: L10n.addonFlowPriceLabel(
                                addonQuote.cost.premium.gross?.formattedAmount ?? ""
                            ),
                            color: .grey,
                            colorLevel: .one
                        )
                        .hFieldSize(.small)
                    },
                    onTap: { changeAddonVm.selectAddon(id: addonQuote.id, addonType: .car) }
                )
                .padding(.top, .padding16)
            }
        }
    }

    @hColorBuilder
    private func checkmarkColor(isSelected: Bool, isDisabled: Bool) -> some hColor {
        if isSelected && !isDisabled { hColorBase(.green) } else { hGrayscaleTranslucent.greyScaleTranslucent300 }
    }

    @hColorBuilder
    private func titleColor(isDisabled: Bool) -> some hColor {
        if isDisabled { hTextColor.Translucent.secondary } else { hTextColor.Opaque.primary }
    }

    @hColorBuilder
    private func subTitleColor(isDisabled: Bool) -> some hColor {
        if isDisabled { hTextColor.Translucent.secondary } else { hTextColor.Opaque.secondary }
    }

    @ViewBuilder
    private func addonToggleRow<Trailing: View>(
        title: String,
        subtitle: String,
        isSelected: Bool,
        isDisabled: Bool = false,
        @ViewBuilder trailingView: () -> Trailing,
        onTap: @escaping () -> Void = {}
    ) -> some View {
        let checkmarkColor = checkmarkColor(isSelected: isSelected, isDisabled: isDisabled)
        let titleColor = titleColor(isDisabled: isDisabled)
        let subTitleColor = subTitleColor(isDisabled: isDisabled)
        ZStack {
            HStack(alignment: .top) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(checkmarkColor)
                    .font(.title2)

                VStack(alignment: .leading, spacing: .padding4) {
                    HStack {
                        hText(title).foregroundColor(titleColor)
                        Spacer()
                        trailingView()
                    }
                    hText(subtitle, style: .label).foregroundColor(subTitleColor)
                }
            }
            .padding(.init(top: .padding18, leading: .padding16, bottom: .padding24, trailing: .padding16))
        }
        .onTapGesture { onTap() }
        .accessibilityAction { onTap() }
        .accessibilityHint(L10n.voiceoverPressTo)  // TODO: fix hint
        .background(hSurfaceColor.Opaque.primary)
        .cornerRadius(.cornerRadiusL)
    }

    @ViewBuilder
    private func travelAddonSection(travelOffer: AddonOfferV2) -> some View {
        if let selectedQuote = changeAddonVm.selectedAddons.first {
            Group {
                DropdownView(
                    value: selectedQuote.displayTitle,
                    placeHolder: L10n.addonFlowSelectDaysPlaceholder
                ) {
                    changeAddonNavigationVm.isSelectableAddonPresented = travelOffer.selectableOffer
                }
                .disabled(changeAddonVm.disableDropDown)
                .padding(.top, .padding16)
                .hBackgroundOption(option: changeAddonVm.disableDropDown ? [.locked] : [])
                .hWithoutHorizontalPadding([.section])
                .accessibilityHidden(false)
            }
            .accessibilityElement(children: .combine)
            .accessibilityHint(L10n.voiceoverPressTo + L10n.addonFlowSelectSuboptionTitle)
            .accessibilityAction {
                changeAddonNavigationVm.isSelectableAddonPresented = travelOffer.selectableOffer
            }
        }
    }

    private var coverageButtonView: some View {
        hButton(
            .medium,
            .ghost,
            content: .init(title: L10n.addonFlowCoverButton)
        ) {
            let perils = changeAddonVm.selectedAddons.flatMap(\.addonVariant.perils)

            changeAddonNavigationVm.isLearnMorePresented = .init(
                .init(
                    title: L10n.addonFlowTravelInformationTitle,
                    description: L10n.addonFlowTravelInformationDescription,
                    perils: perils
                )
            )
        }
        .hButtonWithBorder
        .hButtonTakeFullWidth(true)
    }
}

#Preview("Travel Addons") {
    Dependencies.shared.add(module: Module { () -> AddonsClient in AddonsClientDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return ChangeAddonScreen(
        changeAddonVm: .init(
            config: .init(contractId: "contractId", exposureName: "exposureName", displayName: "displayName"),
            addonSource: .insurances
        )
    )
    .environmentObject(ChangeAddonNavigationViewModel(input: .init(addonSource: .insurances)))
}

#Preview("Car Addons") {
    Dependencies.shared.add(module: Module { () -> AddonsClient in AddonsClientDemo(offer: testCarAddonRisk) })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return ChangeAddonScreen(
        changeAddonVm: .init(
            config: .init(contractId: "contractId", exposureName: "exposureName", displayName: "displayName"),
            addonSource: .insurances
        )
    )
    .environmentObject(ChangeAddonNavigationViewModel(input: .init(addonSource: .insurances)))
}
