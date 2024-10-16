import SwiftUI
import hCore
import hCoreUI
import hGraphQL

public struct ChangeTierLandingScreen: View {
    @ObservedObject var vm: ChangeTierViewModel
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel

    init(
        vm: ChangeTierViewModel
    ) {
        self.vm = vm
    }

    public var body: some View {
        if vm.missingQuotes {
            InfoScreen(text: L10n.terminationNoTierQuotesSubtitle, dismissButtonTitle: L10n.embarkGoBackButton) {
                changeTierNavigationVm.missingQuotesGoBackPressed()
            }
        } else {
            ProcessingStateView(
                loadingViewText: L10n.tierFlowProcessing,
                successViewTitle: nil,
                successViewBody: nil,
                successViewButtonAction: nil,
                errorViewButtons: .init(
                    actionButton: .init(
                        buttonTitle: nil,
                        buttonAction: {
                            vm.fetchTiers()
                        }
                    ),
                    dismissButton:
                        .init(
                            buttonTitle: L10n.generalCloseButton,
                            buttonAction: {
                                changeTierNavigationVm.router.dismiss()
                            }
                        )
                ),
                state: $vm.viewState
            )
            .hCustomSuccessView {
                succesView
            }
        }
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
                        .padding(.bottom, 16)
                }
            }
            .hDisableScroll
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
                .hWithTransparentColor
                .hWithoutHorizontalPadding

                hRow {
                    PriceField(
                        newPremium: vm.newPremium,
                        currentPremium: vm.currentPremium
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
                    .hFieldLockedState
                    .colorScheme(.light)
                    .hWithTransparentColor
                    .hFieldTrailingView {
                        Image(uiImage: hCoreUIAssets.lock.image)
                            .foregroundColor(hTextColor.Opaque.secondary)
                    }
                    hText(L10n.tierFlowLockedInfoDescription, style: .label)
                        .foregroundColor(hTextColor.Translucent.secondary)
                        .padding(.leading, .padding16)
                }
            }
            .padding(.bottom, 8)
        } else {
            DropdownView(
                value: vm.selectedTier?.name ?? "",
                placeHolder: vm.selectedTier != nil
                    ? L10n.tierFlowCoverageLabel : L10n.tierFlowCoveragePlaceholder
            ) {
                changeTierNavigationVm.isEditTierPresented = true
            }
            .colorScheme(.light)
        }
    }

    @ViewBuilder
    private var deductibleView: some View {
        if !vm.canEditDeductible {
            hSection {
                hFloatingField(
                    value: vm.selectedQuote?.deductableAmount?.formattedAmount ?? "",
                    placeholder: L10n.tierFlowDeductibleLabel
                ) {}
                .hFieldLockedState
                .colorScheme(.light)
                .hWithTransparentColor
                .hFieldTrailingView {
                    Image(uiImage: hCoreUIAssets.lock.image)
                        .foregroundColor(hTextColor.Opaque.secondary)
                }
            }
            .padding(.bottom, 8)
        } else {
            DropdownView(
                value: vm.selectedQuote?.deductableAmount?.formattedAmount ?? "",
                placeHolder: vm.selectedQuote != nil
                    ? L10n.tierFlowDeductibleLabel : L10n.tierFlowDeductiblePlaceholder
            ) {
                changeTierNavigationVm.isEditDeductiblePresented = true
            }
            .disabled(vm.selectedTier == nil)
            .colorScheme(.light)
        }
    }

    private var buttons: some View {
        hSection {
            VStack(spacing: .padding8) {
                hButton.LargeButton(type: .ghost) {
                    changeTierNavigationVm.isCompareTiersPresented = true
                } content: {
                    hText(vm.tiers.count == 1 ? L10n.tierFlowShowCoverage : L10n.tierFlowCompareButton, style: .body1)
                }
                hButton.LargeButton(type: .primary) {
                    switch vm.changeTierInput {
                    case .contractWithSource:
                        changeTierNavigationVm.router.push(ChangeTierRouterActions.summary)
                    case let .existingIntent(_, onSelect):
                        if let selectedTier = vm.selectedTier, let selectedDeductible = vm.selectedQuote {
                            onSelect((selectedTier, selectedDeductible))
                        }
                    }
                } content: {
                    hText(L10n.generalContinueButton)
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
