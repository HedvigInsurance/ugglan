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
        if let selectableOffer = changeAddonVm.addonOffer?.quote.selectableOffer {
            travelAddonSection(for: selectableOffer)
        } else if let carOffer = changeAddonVm.addonOffer?.quote.toggleableOffer {
            carAddonSection(carOffer: changeAddonVm.addonOffer!)
        }
    }

    @ViewBuilder
    private func carAddonSection(carOffer: AddonOfferV2) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            hText(carOffer.quote.displayTitle)
            hText(carOffer.quote.displayDescription, style: .label)
                .foregroundColor(hTextColor.Translucent.secondary)
                .padding(.top, .padding8)

            ForEach(carOffer.activeAddons) { activeAddon in
                addonToggleRow(
                    title: activeAddon.displayTitle,
                    subtitle: activeAddon.displayDescription,
                    isSelected: true,
                    isDisabled: true,
                    trailingView: {
                        hPill(text: L10n.addonBadgeActive, color: .green)
                            .hFieldSize(.small)
                    }
                )
                .padding(.top, .padding16)
            }

            ForEach(carOffer.toggleableAddons) { addonQuote in
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
        subtitle: String?,
        isSelected: Bool,
        isDisabled: Bool = false,
        @ViewBuilder trailingView: () -> Trailing,
        onTap: @escaping () -> Void = {}
    ) -> some View {
        ZStack {
            HStack(alignment: .top) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(checkmarkColor(isSelected: isSelected, isDisabled: isDisabled))
                    .font(.title2)

                VStack(alignment: .leading, spacing: .padding4) {
                    HStack {
                        hText(title)
                            .foregroundColor(titleColor(isDisabled: isDisabled))
                        Spacer()
                        trailingView()
                    }
                    hText(subtitle ?? "", style: .label)
                        .foregroundColor(subTitleColor(isDisabled: isDisabled))
                }
            }
            .padding(.init(top: .padding18, leading: .padding16, bottom: .padding24, trailing: .padding16))
        }
        .onTapGesture { onTap() }
        .background(hSurfaceColor.Opaque.primary)
        .cornerRadius(.cornerRadiusL)
    }

    @ViewBuilder
    private func travelAddonSection(for selectable: AddonOfferSelectable) -> some View {
        if let selectedQuote = changeAddonVm.selectedAddons.first {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    hText(selectable.fieldTitle)
                    Spacer()
                    hPill(
                        text: L10n.addonFlowPriceLabel(
                            changeAddonVm.getGrossPriceDifference(for: selectedQuote).formattedAmount
                        ),
                        color: .grey,
                        colorLevel: .one
                    )
                    .hFieldSize(.small)
                }

                hText(selectable.selectionDescription, style: .label)
                    .foregroundColor(hTextColor.Translucent.secondary)
                    .padding(.top, .padding8)

                DropdownView(
                    value: selectedQuote.displayTitle,
                    placeHolder: L10n.addonFlowSelectDaysPlaceholder
                ) {
                    changeAddonNavigationVm.isSelectableAddonPresented = selectable
                }
                .disabled(changeAddonVm.disableDropDown(for: selectable))
                .padding(.top, .padding16)
                .hBackgroundOption(option: changeAddonVm.disableDropDown(for: selectable) ? [.locked] : [])
                .hWithoutHorizontalPadding([.section])
                .accessibilityHidden(false)
            }
            .accessibilityElement(children: .combine)
            .accessibilityHint(L10n.voiceoverPressTo + L10n.addonFlowSelectSuboptionTitle)
            .accessibilityAction {
                changeAddonNavigationVm.isSelectableAddonPresented = selectable
            }
            .fixedSize(horizontal: false, vertical: true)
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

#Preview {
    Dependencies.shared.add(module: Module { () -> AddonsClient in AddonsClientDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return ChangeAddonScreen(changeAddonVm: .init(contractId: "id", addonSource: .insurances))
        .environmentObject(ChangeAddonNavigationViewModel(input: .init(addonSource: .insurances)))
}
