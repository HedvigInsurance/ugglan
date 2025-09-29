import SwiftUI
import hCore
import hCoreUI

public struct ChangeTierLandingScreen: View {
    @ObservedObject var vm: ChangeTierViewModel
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel
    @SwiftUI.Environment(\.colorScheme) private var colorScheme

    init(
        vm: ChangeTierViewModel
    ) {
        self.vm = vm
    }

    public var body: some View {
        if vm.missingQuotes {
            InfoScreen(text: L10n.terminationNoTierQuotesSubtitle, dismissButtonTitle: L10n.embarkGoBackButton) {
                [weak changeTierNavigationVm] in
                changeTierNavigationVm?.missingQuotesGoBackPressed()
            }
        } else if vm.dataProviderViewState.isError {
            GenericErrorView(
                description: L10n.General.defaultError,
                formPosition: .center
            )
            .hStateViewButtonConfig(dataLoaderErrorButtons)
        } else {
            ProcessingStateView(
                loadingViewText: L10n.tierFlowProcessing,
                state: $vm.viewState,
                duration: 6
            )
            .hCustomSuccessView {
                succesView
            }
            .hStateViewButtonConfig(errorButtons)
        }
    }

    private var errorButtons: StateViewButtonConfig {
        .init(
            actionButton: .init(
                buttonAction: { [weak vm] in
                    vm?.fetchTiers()
                }
            ),
            dismissButton:
                .init(
                    buttonAction: { [weak changeTierNavigationVm] in
                        changeTierNavigationVm?.router.dismiss()
                    }
                )
        )
    }

    private var dataLoaderErrorButtons: StateViewButtonConfig {
        .init(
            actionButton: .init(
                buttonAction: { [weak vm] in
                    vm?.calculateTotal()
                }
            ),
            dismissButton:
                .init(
                    buttonAction: { [weak changeTierNavigationVm] in
                        changeTierNavigationVm?.router.dismiss()
                    }
                )
        )
    }

    var succesView: some View {
        hForm {}
            .hFormTitle(
                title: .init(
                    .small,
                    .body2,
                    L10n.tierFlowTitle,
                    alignment: .leading
                ),
                subTitle: .init(
                    .small,
                    .body2,
                    L10n.tierFlowSubtitle
                )
            )
            .hFormAttachToBottom {
                VStack(spacing: .padding16) {
                    informationCard
                    buttons
                }
            }
    }

    private var informationCard: some View {
        CardView {
            hRow {
                ContractInformation(
                    displayName: vm.displayName,
                    exposureName: vm.exposureName,
                    pillowImage: vm.typeOfContract?.pillowType.bgImage
                )
            }

            VStack(spacing: .padding4) {
                editTierView
                addonView
                if vm.showDeductibleField {
                    deductibleView
                }
            }
            .hFieldSize(.small)
            if !vm.displayItemList.isEmpty {
                VStack(spacing: .padding4) {
                    ForEach(vm.displayItemList, id: \.displayTitle) { disocuntItem in
                        QuoteDisplayItemView(displayItem: disocuntItem)
                    }
                }
                .padding(.top, .padding16)
                .accessibilityElement(children: .combine)
            }
            if vm.newTotalCost != nil {
                hRow {
                    PriceField(
                        viewModel: .init(
                            initialValue: vm.shouldShowOldPrice ? vm.newTotalCost?.gross : nil,
                            newValue: vm.newTotalCost?.net ?? .sek(0),
                            subTitle: getPriceSubtitle()
                        )
                    )
                    .hWithStrikeThroughPrice(setTo: .crossOldPrice)
                }
            } else {
                Spacing(height: Float(.padding16))
            }
        }
    }

    private func getPriceSubtitle() -> String? {
        if let currentPremium = vm.currentTotalCost, vm.newTotalCost != currentPremium {
            let formattedAmount = currentPremium.net?.priceFormat(PriceFormatting.perMonth) ?? ""
            return L10n.tierFlowPreviousPrice(formattedAmount)
        }
        return nil
    }

    @ViewBuilder
    private var editTierView: some View {
        if !vm.canEditTier {
            hSection {
                VStack(alignment: .leading, spacing: .padding4) {
                    hFloatingField(
                        value: vm.selectedTier?.name ?? "",
                        placeholder: L10n.tierFlowCoverageLabel
                    ) {}
                    .hBackgroundOption(option: [.locked])
                    .hFieldTrailingView {
                        hCoreUIAssets.lock.view
                            .foregroundColor(hTextColor.Translucent.secondary)
                    }
                    hText(L10n.tierFlowLockedInfoDescription, style: .label)
                        .foregroundColor(hTextColor.Translucent.secondary)
                        .padding(.leading, .padding16)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.bottom, .padding8)
        } else {
            DropdownView(
                value: vm.selectedTier?.name ?? "",
                placeHolder: vm.selectedTier != nil
                    ? L10n.tierFlowCoverageLabel : L10n.tierFlowCoveragePlaceholder
            ) { [weak vm, weak changeTierNavigationVm] in
                let selectedItem = vm?.selectedTier?.name ?? vm?.tiers.first?.name
                changeTierNavigationVm?.isEditTierPresented = .init(
                    selectedItem: selectedItem,
                    type: .tiers(tiers: vm?.tiers.sorted(by: { $0.level < $1.level }) ?? [])
                )
            }
            .accessibilityHint(L10n.voiceoverPressTo + L10n.contractEditInfo)
        }
    }

    @ViewBuilder
    private var addonView: some View {
        ForEach(vm.addonQuotes) { [weak vm, weak changeTierNavigationVm] quote in
            DropdownView(
                value: vm?.excludedAddonTypes.contains(quote.addonSubtype) ?? false
                    ? L10n.tierFlowAddonNoCoverageLabel : (quote.displayName ?? ""),
                placeHolder: L10n.tierFlowAddonLabel
            ) {
                changeTierNavigationVm?.isEditTierPresented = .init(
                    selectedItem: vm?.selectedAddon?.displayName ?? quote.displayName,
                    type: .addon(addon: quote)
                )
            }
            .accessibilityHint(L10n.voiceoverPressTo + L10n.contractEditInfo)
        }
    }

    @ViewBuilder
    private var deductibleView: some View {
        if !vm.canEditDeductible {
            hSection {
                hFloatingField(
                    value: vm.selectedQuote?.displayTitle ?? "",
                    placeholder: L10n.tierFlowDeductibleLabel
                ) {}
                .hBackgroundOption(option: [.locked])
                .hFieldTrailingView {
                    hCoreUIAssets.lock.view
                        .foregroundColor(hTextColor.Translucent.secondary)
                }
            }
            .padding(.bottom, 8)
        } else {
            DropdownView(
                value: vm.selectedQuote?.displayTitle ?? "",
                placeHolder: vm.selectedQuote != nil
                    ? L10n.tierFlowDeductibleLabel : L10n.tierFlowDeductiblePlaceholder
            ) { [weak vm, weak changeTierNavigationVm] in
                let quotes = {
                    if !(vm?.selectedTier?.quotes.isEmpty ?? true) {
                        return vm?.selectedTier?.quotes ?? []
                    } else {
                        return vm?.tiers.first(where: { $0.name == vm?.selectedTier?.name })?.quotes ?? []
                    }
                }()
                changeTierNavigationVm?.isEditTierPresented = .init(
                    selectedItem: vm?.selectedQuote?.id ?? vm?.selectedTier?.quotes.first?.id,
                    type: .deductible(
                        quotes: quotes.sorted(by: { $0.newTotalCost.net?.value ?? 0 > $1.newTotalCost.net?.value ?? 0 })
                    )
                )
            }
            .disabled(vm.selectedTier == nil)
            .hFieldSize(.small)
            .accessibilityHint(L10n.voiceoverPressTo + L10n.contractEditInfo)
        }
    }

    private var buttons: some View {
        hSection {
            VStack(spacing: .padding8) {
                hContinueButton { [weak vm, weak changeTierNavigationVm] in
                    guard let vm, let changeTierNavigationVm else { return }
                    switch vm.changeTierInput {
                    case .contractWithSource:
                        changeTierNavigationVm.router.push(ChangeTierRouterActions.summary)
                    case let .existingIntent(_, onSelect):
                        if let selectedTier = vm.selectedTier, let selectedDeductible = vm.selectedQuote, let onSelect {
                            onSelect((selectedTier, selectedDeductible))
                        } else {
                            changeTierNavigationVm.router.push(ChangeTierRouterActions.summary)
                        }
                    }
                }
                .disabled(!vm.isValid)

                hButton(
                    .large,
                    .ghost,
                    content: .init(
                        title: vm.tiers.count == 1 ? L10n.tierFlowShowCoverage : L10n.tierFlowCompareButton
                    ),
                    { [weak changeTierNavigationVm] in
                        changeTierNavigationVm?.isCompareTiersPresented = true
                    }
                )
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> ChangeTierClient in ChangeTierClientDemo() })
    let inputData = ChangeTierInputData(source: .betterCoverage, contractId: "")
    return ChangeTierLandingScreen(
        vm: .init(
            changeTierInput: ChangeTierInput.contractWithSource(data: inputData)
        )
    )
    .environmentObject(
        ChangeTierNavigationViewModel(
            changeTierContractsInput: .init(source: .betterCoverage, contracts: []),
            onChangedTier: {}
        )
    )
}
