import SwiftUI
import hCore
import hCoreUI

struct ChangeAddonScreen: View {
    @EnvironmentObject var navigationVm: ChangeAddonNavigationViewModel
    @ObservedObject var vm: ChangeAddonViewModel

    init(vm: ChangeAddonViewModel) {
        self.vm = vm
    }

    var body: some View {
        successView
            .loading($vm.fetchAddonsViewState)
            .disabled(vm.fetchingCostState == .loading)
            .trackErrorState(for: $vm.fetchingCostState)
            .hStateViewButtonConfig(
                vm.fetchAddonsViewState.isError
                    ? .init(
                        actionButton: .init { Task { await vm.getAddons() } },
                        dismissButton: .init { navigationVm.router.dismiss() }
                    )
                    : .init(
                        actionButton: .init { vm.fetchingCostState = .success },
                        dismissButton: .init(buttonTitle: L10n.generalCloseButton) {
                            vm.fetchingCostState = .success
                            navigationVm.router.dismiss()
                        }
                    )
            )
    }

    @ViewBuilder
    private var successView: some View {
        if let offer = vm.addonOffer {
            hForm {}
                .hFormTitle(
                    title: .init(.small, .body2, offer.pageTitle, alignment: .leading),
                    subTitle: .init(.small, .body2, offer.pageDescription, alignment: .leading)
                )
                .hFormAttachToBottom {
                    CardView {
                        hRow { addOnSection }
                        hRow { coverageButtonView }
                            .verticalPadding(0)
                            .padding(.bottom, .padding16)
                    }

                    hSection {
                        hContinueButton {
                            Task {
                                await vm.getAddonOfferCost()
                                guard vm.addonOfferCost != nil else { return }
                                navigationVm.router.push(ChangeAddonRouterActions.summary)
                            }
                        }
                        .disabled(!vm.allowToContinue)
                        .hButtonIsLoading(vm.fetchingCostState == .loading)
                    }
                    .sectionContainerStyle(.transparent)
                }
        }
    }

    @ViewBuilder
    private var addOnSection: some View {
        if let offer = vm.addonOffer {
            VStack(alignment: .leading, spacing: .padding8) {
                HStack {
                    hText(offer.quote.displayTitle)
                    Spacer()
                    if let priceIncrease = vm.getAddonPriceChange() {
                        hPill(
                            text: L10n.addonFlowPriceLabel(priceIncrease.gross.formattedAmount),
                            color: .grey,
                            colorLevel: .one
                        )
                        .hFieldSize(.small)
                    }
                }

                hText(offer.quote.displayDescription, style: .label)
                    .foregroundColor(hTextColor.Translucent.secondary)
                    .padding(.bottom, .padding8)

                switch offer.quote.addonOfferContent {
                case .selectable(let selectable):
                    selectableAddonSection(selectable: selectable)
                case .toggleable(let toggleable):
                    toggleableAddonSection(activeAddons: offer.quote.activeAddons, toggleable: toggleable)
                }
            }
        }
    }

    @ViewBuilder
    private func toggleableAddonSection(activeAddons: [ActiveAddon], toggleable: AddonOfferToggleable) -> some View {
        VStack(alignment: .leading, spacing: .padding4) {
            ForEach(toggleable.quotes) { addon in
                AddonOptionRow(
                    title: addon.displayTitle,
                    subtitle: addon.displayDescription,
                    isSelected: vm.isAddonSelected(addon),
                    trailingView: {
                        hPill(
                            text: L10n.addonFlowPriceLabel(addon.cost.premium.gross.formattedAmount),
                            color: .grey,
                            colorLevel: .one
                        )
                        .hFieldSize(.small)
                    },
                    onTap: { vm.selectAddon(addon: addon) }
                )
            }

            ForEach(activeAddons) { activeAddon in
                AddonOptionRow(
                    title: activeAddon.displayTitle,
                    subtitle: activeAddon.displayDescription ?? "",
                    isSelected: true,
                    isDisabled: true,
                    trailingView: {
                        hPill(text: L10n.addonBadgeActive, color: .green)
                            .hFieldSize(.small)
                    }
                )
            }
        }
    }

    @ViewBuilder
    private func selectableAddonSection(selectable: AddonOfferSelectable) -> some View {
        if let selectedQuote = vm.selectedAddons.first {
            Group {
                let isDropDownDisabled = vm.isDropDownDisabled(for: selectable)
                DropdownView(
                    value: selectedQuote.displayTitle,
                    placeHolder: L10n.addonFlowSelectDaysPlaceholder
                ) {
                    navigationVm.isSelectableAddonPresented = selectable
                }
                .disabled(isDropDownDisabled)
                .padding(.top, .padding16)
                .hBackgroundOption(option: isDropDownDisabled ? [.locked] : [])
                .hWithoutHorizontalPadding([.section])
                .accessibilityHidden(false)
            }
            .accessibilityElement(children: .combine)
            .accessibilityHint(L10n.voiceoverPressTo + L10n.addonFlowSelectSuboptionTitle)
            .accessibilityAction { navigationVm.isSelectableAddonPresented = selectable }
        }
    }

    private var coverageButtonView: some View {
        guard let offer = vm.addonOffer else { return EmptyView().asAnyView }
        return hButton(
            .medium,
            .ghost,
            content: .init(title: L10n.addonFlowCoverButton)
        ) {
            navigationVm.isLearnMorePresented = .init(
                .init(
                    title: offer.whatsIncludedPageTitle,
                    description: offer.whatsIncludedPageDescription,
                    perilGroups: getPerilGroups()
                )
            )
        }
        .hButtonWithBorder
        .hButtonTakeFullWidth(true)
        .asAnyView
    }
}

extension ChangeAddonScreen {
    fileprivate func getPerilGroups() -> [AddonInfo.PerilGroup] {
        let quotes: [AddonOfferQuote] =
            switch vm.addonOffer!.quote.addonOfferContent {
            case .selectable(let selectable): selectable.quotes
            case .toggleable(let toggleable): toggleable.quotes
            }

        let uniqueGroups =
            quotes
            .uniqued(on: \.addonVariant.product)
            .map { AddonInfo.PerilGroup(title: $0.addonVariant.displayName, perils: $0.addonVariant.perils) }

        return uniqueGroups
    }
}

@MainActor
private func changeAddonPreview(offer: AddonOffer) -> some View {
    Dependencies.shared.add(module: Module { () -> AddonsClient in AddonsClientDemo(offer: offer) })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return ChangeAddonScreen(
        vm: .init(
            config: .init(contractId: "contractId", exposureName: "exposureName", displayName: "displayName"),
            addonSource: .insurances
        )
    )
    .environmentObject(ChangeAddonNavigationViewModel(input: .init(addonSource: .insurances)))
}

#Preview("Travel") { changeAddonPreview(offer: testTravelOfferNoActive) }
#Preview("Travel with Active addon") { changeAddonPreview(offer: testTravelOffer45Days) }
#Preview("Car") { changeAddonPreview(offer: testCarOfferNoActive) }
#Preview("Car with Active addon") { changeAddonPreview(offer: testCarAddonRisk) }
