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
            .disabled(vm.fetchingCostState == .loading)
            .trackErrorState(for: $vm.fetchingCostState)
            .hStateViewButtonConfig(
                .init(
                    actionButton: .init { [weak vm] in vm?.fetchingCostState = .success },
                    dismissButton: .init(buttonTitle: L10n.generalCloseButton) { [weak vm, weak navigationVm] in
                        vm?.fetchingCostState = .success
                        navigationVm?.router.dismiss()
                    }
                )
            )
    }

    private var successView: some View {
        hForm {}
            .hFormTitle(
                title: .init(.small, .body2, vm.offer.pageTitle, alignment: .leading),
                subTitle: .init(.small, .body2, vm.offer.pageDescription, alignment: .leading)
            )
            .hFormAttachToBottom {
                CardView {
                    hRow { addOnSection }
                    hRow { coverageButtonView }
                        .verticalPadding(0)
                        .padding(.bottom, .padding16)
                }

                hSection {
                    hContinueButton { [weak vm, weak navigationVm] in
                        Task {
                            await vm?.getAddonOfferCost()
                            guard vm?.addonOfferCost != nil else { return }
                            navigationVm?.router.push(ChangeAddonRouterActions.summary)
                        }
                    }
                    .disabled(!vm.allowToContinue)
                    .hButtonIsLoading(vm.fetchingCostState == .loading)
                }
                .sectionContainerStyle(.transparent)
            }
    }

    private var addOnSection: some View {
        VStack(alignment: .leading, spacing: .padding8) {
            HStack {
                hText(vm.offer.quote.displayTitle)
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

            hText(vm.offer.quote.displayDescription, style: .label)
                .foregroundColor(hTextColor.Translucent.secondary)
                .padding(.bottom, .padding8)

            switch vm.offer.quote.addonOfferContent {
            case .selectable(let selectable):
                selectableAddonSection(selectable: selectable)
            case .toggleable(let toggleable):
                toggleableAddonSection(activeAddons: vm.offer.quote.activeAddons, toggleable: toggleable)
            }
        }
    }

    private func toggleableAddonSection(activeAddons: [ActiveAddon], toggleable: AddonOfferToggleable) -> some View {
        VStack(alignment: .leading, spacing: .padding4) {
            // Added unowned vm and seperated view to avoid memory leak and make sure that view is working corectly
            ForEach(toggleable.quotes) { [unowned vm] addon in
                AddonOptionToggableView(addon: addon, vm: vm)
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

    private func selectableAddonSection(selectable: AddonOfferSelectable) -> some View {
        Group {
            let isDropDownDisabled = vm.isDropDownDisabled(for: selectable)
            DropdownView(
                value: vm.selectedAddons.first!.displayTitle,
                placeHolder: L10n.addonFlowSelectDaysPlaceholder
            ) { [weak navigationVm] in
                navigationVm?.isSelectableAddonPresented = selectable
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

    private var coverageButtonView: some View {
        hButton(
            .medium,
            .ghost,
            content: .init(title: L10n.addonFlowCoverButton)
        ) { [weak navigationVm, weak vm] in
            guard let vm, let navigationVm else { return }
            navigationVm.isLearnMorePresented = .init(
                .init(
                    title: vm.offer.whatsIncludedPageTitle,
                    description: vm.offer.whatsIncludedPageDescription,
                    perilGroups: vm.getPerilGroups()
                )
            )
        }
        .hButtonWithBorder
        .hButtonTakeFullWidth(true)
    }
}

private struct AddonOptionToggableView: View {
    let addon: AddonOfferQuote
    @ObservedObject var vm: ChangeAddonViewModel
    var body: some View {
        HStack(alignment: .top, spacing: .padding4) {
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
                onTap: { [weak vm] in vm?.selectAddon(addon: addon) }
            )
        }
    }
}

extension ChangeAddonViewModel {
    fileprivate func getPerilGroups() -> [AddonInfo.PerilGroup] {
        let quotes: [AddonOfferQuote] =
            switch self.offer.quote.addonOfferContent {
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
    return ChangeAddonScreen(vm: .init(offer: offer))
        .environmentObject(ChangeAddonNavigationViewModel(offer: offer))
}

#Preview("Travel") { changeAddonPreview(offer: testTravelOfferNoActive) }
#Preview("Travel with Active addon") { changeAddonPreview(offer: testTravelOffer45Days) }
#Preview("Car") { changeAddonPreview(offer: testCarOfferNoActive) }
#Preview("Car with Active addon") { changeAddonPreview(offer: testCarAddonRisk) }
