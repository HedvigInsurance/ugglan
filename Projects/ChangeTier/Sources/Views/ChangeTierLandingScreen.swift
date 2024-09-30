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
                    HStack(spacing: .padding12) {
                        Image(uiImage: hCoreUIAssets.pillowHome.image)
                            .resizable()
                            .frame(width: 48, height: 48)
                        VStack(alignment: .leading, spacing: 0) {
                            hText(vm.displayName ?? "")
                            hText(vm.exposureName ?? "")
                                .foregroundColor(hTextColor.Opaque.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                VStack(spacing: .padding4) {
                    if !vm.canEditTier {
                        hSection {
                            hFloatingField(value: vm.selectedTier?.name ?? "", placeholder: L10n.tierFlowCoverageLabel)
                            {}
                            .hFieldLockedState
                            .hFieldTrailingView {
                                Image(uiImage: hCoreUIAssets.lock.image)
                                    .foregroundColor(hTextColor.Opaque.secondary)
                            }
                            hText(L10n.tierFlowLockedInfoDescription, style: .label)
                                .foregroundColor(hTextColor.Translucent.secondary)
                                .padding(.horizontal, .padding16)
                                .padding(.top, .padding4)
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

                    DropdownView(
                        value: vm.selectedDeductible?.deductibleAmount?.formattedAmount ?? "",
                        placeHolder: vm.selectedDeductible != nil
                            ? L10n.tierFlowDeductibleLabel : L10n.tierFlowDeductiblePlaceholder
                    ) {
                        changeTierNavigationVm.isEditDeductiblePresented = true
                    }
                    .disabled(vm.selectedTier == nil)
                }
                .hFieldSize(.small)
                .hWithTransparentColor
                .hWithoutHorizontalPadding

                hRow {
                    HStack(alignment: .top) {
                        hText(L10n.tierFlowTotal)
                        Spacer()
                        VStack(alignment: .trailing, spacing: 0) {
                            hText(newPremium?.formattedAmountPerMonth ?? currentPremium?.formattedAmountPerMonth ?? "")

                            if let newPremium, newPremium != currentPremium {
                                hText(
                                    L10n.tierFlowPreviousPrice(currentPremium?.formattedAmountPerMonth ?? ""),
                                    style: .label
                                )
                                .foregroundColor(hTextColor.Opaque.secondary)
                            }
                        }
                    }
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
                    /** TODO: ADD ACTION **/
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

public class ChangeTierViewModel: ObservableObject {
    @Inject var service: ChangeTierClient
    @Published var viewState: ChangeTierViewState = .loading
    @Published var displayName: String?
    var exposureName: String?
    var tiers: [Tier] = []

    var contractId: String
    var changeTierSource: ChangeTierSource

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
                self.displayName = data.tiers.first?.productVariant.displayName
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
}

#Preview{
    Dependencies.shared.add(module: Module { () -> ChangeTierClient in ChangeTierClientDemo() })
    return ChangeTierLandingScreen(vm: .init(contractId: "contractId", changeTierSource: .changeTier))
}
