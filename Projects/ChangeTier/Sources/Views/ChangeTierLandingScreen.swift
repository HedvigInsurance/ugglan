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
                buttonAction: {
                    vm.fetchTiers()
                }
            ),
            dismissButton:
                .init(
                    buttonAction: {
                        changeTierNavigationVm.router.dismiss()
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
                VStack(spacing: .padding4) {
                    informationCard
                    buttons
                }
            }
    }

    private var informationCard: some View {
        hSection {
            VStack(spacing: 0) {
                hRow {
                    ContractInformation(
                        displayName: vm.displayName,
                        exposureName: vm.exposureName,
                        pillowImage: vm.typeOfContract?.pillowType.bgImage
                    )
                }

                VStack(spacing: .padding4) {
                    editTierView
                    if vm.showDeductibleField {
                        deductibleView
                    }
                }
                .hFieldSize(.small)
                .hBackgroundOption(option: (colorScheme == .light) ? [.negative] : [.secondary])

                hRow {
                    PriceFieldView(
                        viewModel: .init(
                            initialValue: vm.currentPremium,
                            newValue: vm.newPremium ?? .sek(0)
                        )
                    )
                }
            }
        }
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
                    .hBackgroundOption(option: [.locked, .secondary, .negative])
                    .hFieldTrailingView {
                        hCoreUIAssets.lock.view
                            .foregroundColor(hTextColor.Translucent.secondary)
                    }
                    hText(L10n.tierFlowLockedInfoDescription, style: .label)
                        .foregroundColor(hTextColor.Translucent.secondary)
                        .padding(.leading, .padding16)
                }
            }
            .padding(.bottom, .padding8)
        } else {
            DropdownView(
                value: vm.selectedTier?.name ?? "",
                placeHolder: vm.selectedTier != nil
                    ? L10n.tierFlowCoverageLabel : L10n.tierFlowCoveragePlaceholder
            ) {
                changeTierNavigationVm.isEditTierPresented = .init(type: .tier)
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
                .hBackgroundOption(option: [.locked, .secondary, .negative])
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
            ) {
                changeTierNavigationVm.isEditTierPresented = .init(type: .deductible)
            }
            .disabled(vm.selectedTier == nil)
            .hFieldSize(.small)
            .accessibilityHint(L10n.voiceoverPressTo + L10n.contractEditInfo)
        }
    }

    private var buttons: some View {
        hSection {
            VStack(spacing: .padding8) {
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
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> ChangeTierClient in ChangeTierClientDemo() })
    let inputData = ChangeTierInputData(source: .betterCoverage, contractId: "")
    return ChangeTierLandingScreen(vm: .init(changeTierInput: ChangeTierInput.contractWithSource(data: inputData)))
}
