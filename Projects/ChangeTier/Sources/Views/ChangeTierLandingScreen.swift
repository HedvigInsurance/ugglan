import SwiftUI
import hCore
import hCoreUI
import hGraphQL

struct ChangeTierLandingScreen: View {
    @ObservedObject var vm: SelectTierViewModel
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel
    @EnvironmentObject var router: Router
    var contractId: String

    init(
        vm: SelectTierViewModel,
        contractId: String
    ) {
        self.vm = vm
        self.contractId = contractId
        vm.contractId = contractId
    }

    var body: some View {
        switch vm.viewState {
        case .loading:
            loadingView
        case .success:
            succesView
        case .error:
            errorView
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
                    if !vm.canEditTier {
                        hSection {
                            hFloatingField(value: vm.selectedTier?.name ?? "", placeholder: L10n.tierFlowCoverageLabel)
                            {
                                changeTierNavigationVm.isTierLockedInfoViewPresented = true
                            }
                            .hFieldLockedState
                            .hFieldTrailingView {
                                Image(uiImage: hCoreUIAssets.lock.image)
                                    .foregroundColor(hTextColor.Opaque.secondary)
                            }
                        }
                    } else {
                        DropdownView(value: vm.selectedTier?.name ?? "", placeHolder: L10n.tierFlowCoveragePlaceholder)
                        {
                            changeTierNavigationVm.isEditTierPresented = true
                        }
                    }

                    DropdownView(
                        value: vm.selectedDeductible?.deductibleAmount?.formattedAmount ?? "",
                        placeHolder: L10n.tierFlowDeductiblePlaceholder
                    ) {
                        changeTierNavigationVm.isEditDeductiblePresented = true
                    }
                    .disabled(vm.selectedTier == nil)
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
                ProgressView()
                    .frame(width: UIScreen.main.bounds.width * 0.53)
                    .progressViewStyle(hProgressViewStyle())
                Spacer()
            }
        }
        .sectionContainerStyle(.transparent)
    }

    var errorView: some View {
        GenericErrorView(
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

enum ChangeTierViewState {
    case loading
    case success
    case error
}

public class SelectTierViewModel: ObservableObject {
    @Inject var service: SelectTierClient
    @Published var viewState: ChangeTierViewState = .loading
    @Published var displayName: String?
    var exposureName: String?
    var tiers: [Tier] = []
    @Published var contractId: String?

    var currentPremium: MonetaryAmount?
    var currentTier: Tier?
    var currentDeductible: Deductible?
    var newPremium: MonetaryAmount?
    var canEditTier: Bool = false

    @Published var selectedTier: Tier?
    @Published var selectedDeductible: Deductible?

    var isValid: Bool {
        let selectedTierIsSameAsCurrent = currentTier?.name == selectedTier?.name
        let selectedDeductibleIsSameAsCurrent = currentDeductible == selectedDeductible
        let hasSelectedValues = selectedTier != nil && selectedDeductible != nil

        return hasSelectedValues && !(selectedTierIsSameAsCurrent && selectedDeductibleIsSameAsCurrent)
    }

    init() {
        fetchTiers()
    }

    @MainActor
    func setTier(for tierName: String) {
        withAnimation {
            let newSelectedTier = tiers.first(where: { $0.name == tierName })
            if newSelectedTier != selectedTier {
                self.selectedDeductible = nil
            }
            self.selectedTier = newSelectedTier
        }
    }

    @MainActor
    func setDeductible(for deductibleId: String) {
        withAnimation {
            if let deductible = selectedTier?.deductibles.first(where: { $0.id == deductibleId }) {
                self.selectedDeductible = deductible
            }
        }
    }

    func fetchTiers() {
        self.viewState = .loading
        Task { @MainActor in
            do {
                let data = try await service.getTier(contractId: contractId ?? "")
                self.tiers = data.tiers
                self.displayName = data.tiers.first?.productVariant.displayName
                self.exposureName = data.tiers.first?.exposureName
                self.currentPremium = data.currentPremium

                self.currentTier = data.currentTier
                self.currentDeductible = data.currentDeductible
                self.canEditTier = data.canEditTier

                self.selectedTier = currentTier
                self.selectedDeductible = currentDeductible
                self.newPremium = selectedTier?.premium
                self.viewState = .success
            } catch {
                self.viewState = .error
            }
        }
    }
}

#Preview{
    Dependencies.shared.add(module: Module { () -> SelectTierClient in ChangeTierClientDemo() })
    return ChangeTierLandingScreen(vm: .init(), contractId: "contractId")
}
