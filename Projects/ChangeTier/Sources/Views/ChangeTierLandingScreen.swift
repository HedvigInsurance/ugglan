import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ChangeTierLandingScreen: View {
    @ObservedObject var vm: ChangeTierViewModel
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel
    @EnvironmentObject var router: Router
    @State var progress: Float = 0

    init(
        vm: ChangeTierViewModel
    ) {
        self.vm = vm
    }

    var body: some View {
        switch vm.viewState {
        case .loading:
            loadingView
        case .success:
            succesView
        case let .error(errorMessage):
            errorView(errorMessage: errorMessage)
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
                        exposureName: vm.exposureName
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
        }
    }

    private var deductibleView: some View {
        DropdownView(
            value: vm.selectedDeductible?.deductibleAmount?.formattedAmount ?? "",
            placeHolder: vm.selectedDeductible != nil
                ? L10n.tierFlowDeductibleLabel : L10n.tierFlowDeductiblePlaceholder
        ) {
            changeTierNavigationVm.isEditDeductiblePresented = true
        }
        .disabled(vm.selectedTier == nil)
    }

    private var buttons: some View {
        hSection {
            VStack(spacing: .padding8) {
                hButton.LargeButton(type: .ghost) {
                    changeTierNavigationVm.isCompareTiersPresented = true
                } content: {
                    hText(L10n.tierFlowCompareButton, style: .body1)
                }
                hButton.LargeButton(type: .primary) {
                    router.push(ChangeTierRouterActions.summary)
                } content: {
                    hText(L10n.generalContinueButton)
                }
                .disabled(!vm.isValid)
            }
        }
        .sectionContainerStyle(.transparent)
    }

    var loadingView: some View {
        hSection {
            VStack(spacing: 20) {
                Spacer()
                hText(L10n.tierFlowProcessing)
                ProgressView(value: progress)
                    .frame(width: UIScreen.main.bounds.width * 0.53)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.easeInOut(duration: 1.5).delay(0.5)) {
                                progress = 1
                            }
                        }
                    }
                    .progressViewStyle(hProgressViewStyle())
                Spacer()
            }
        }
        .sectionContainerStyle(.transparent)
    }

    func errorView(errorMessage: String?) -> some View {
        GenericErrorView(
            title: L10n.somethingWentWrong,
            description: errorMessage,
            buttons: .init(
                actionButton: .init(
                    buttonAction: {
                        vm.fetchTiers()
                    }
                ),
                dismissButton: .init(
                    buttonTitle: L10n.generalCloseButton,
                    buttonAction: {
                        router.dismiss()
                    }
                )
            )
        )
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> ChangeTierClient in ChangeTierClientDemo() })
    return ChangeTierLandingScreen(vm: .init(contractId: "contractId", changeTierSource: .changeTier))
}
