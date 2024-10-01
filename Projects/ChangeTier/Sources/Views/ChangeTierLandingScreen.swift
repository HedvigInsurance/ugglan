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

enum ChangeTierViewState {
    case loading
    case success
    case error(errorMessage: String)
}

class ChangeTierViewModel: ObservableObject {
    @Inject private var service: ChangeTierClient
    @Published var viewState: ChangeTierViewState = .loading
    @Published var displayName: String?
    @Published var exposureName: String?
    private(set) var tiers: [Tier] = []
    private var contractId: String
    private var changeTierSource: ChangeTierSource

    @Published var currentPremium: MonetaryAmount?
    var currentTier: Tier?
    private var currentDeductible: Deductible?
    var newPremium: MonetaryAmount?
    @Published var canEditTier: Bool = false

    @Published var selectedTier: Tier?
    @Published var selectedDeductible: Deductible?

    var isValid: Bool {
        let selectedTierIsSameAsCurrent = currentTier?.name == selectedTier?.name
        let selectedDeductibleIsSameAsCurrent = currentDeductible == selectedDeductible
        let isDeductibleValid = selectedDeductible != nil || selectedTier?.deductibles.isEmpty ?? false
        let isTierValid = selectedTier != nil
        let hasSelectedValues = isTierValid && isDeductibleValid

        return hasSelectedValues && !(selectedTierIsSameAsCurrent && selectedDeductibleIsSameAsCurrent)
    }

    var showDeductibleField: Bool {
        return !(selectedTier?.deductibles.isEmpty ?? true) && selectedTier != nil
    }

    init(
        contractId: String,
        changeTierSource: ChangeTierSource
    ) {
        self.contractId = contractId
        self.changeTierSource = changeTierSource
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
            self.newPremium = selectedTier?.premium
        }
    }

    @MainActor
    func setDeductible(for deductibleId: String) {
        withAnimation {
            if let deductible = selectedTier?.deductibles.first(where: { $0.id == deductibleId }) {
                self.selectedDeductible = deductible
                self.newPremium = deductible.premium
            }
        }
    }

    func fetchTiers() {
        withAnimation {
            self.viewState = .loading
        }
        Task { @MainActor in
            do {
                let data = try await service.getTier(
                    contractId: contractId,
                    tierSource: changeTierSource
                )
                self.tiers = data.tiers
                self.displayName = data.tiers.first?.productVariant?.displayName
                self.exposureName = data.tiers.first?.exposureName
                self.currentPremium = data.currentPremium

                self.currentTier = data.currentTier
                self.currentDeductible = data.currentDeductible
                self.canEditTier = data.canEditTier

                self.selectedTier = currentTier
                self.selectedDeductible = currentDeductible
                self.newPremium = selectedTier?.premium

                withAnimation {
                    self.viewState = .success
                }
            } catch let error {
                withAnimation {
                    self.viewState = .error(errorMessage: error.localizedDescription)
                }
            }
        }
    }

    public func commitTier() {
        Task { @MainActor in
            do {
                if let id = selectedTier?.id {
                    try await service.commitTier(
                        quoteId: id
                    )
                }
            }
        }
    }
}

#Preview{
    Dependencies.shared.add(module: Module { () -> ChangeTierClient in ChangeTierClientOctopus() })
    return ChangeTierLandingScreen(vm: .init(contractId: "contractId", changeTierSource: .changeTier))
}
