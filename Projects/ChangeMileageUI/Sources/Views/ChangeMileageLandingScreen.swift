import ChangeMileageCore
import SwiftUI
import hCore
import hCoreUI

struct ChangeMileageLandingScreen: View {
    @Bindable var vm: ChangeMileageViewModel
    @Environment(ChangeMileageNavigationViewModel.self) var navigationVm

    var body: some View {
        // TODO: Add "Fetching mileage options..." / "Hämtar körsträckor..." to Lokalise
        ProcessingStateView(
            loadingViewText: "Hämtar körsträckor...",
            state: $vm.viewState
        )
        .hStateViewCustomSuccessView {
            successView
        }
        .hStateViewButtonConfig(errorButtons)
    }

    private var errorButtons: StateViewButtonConfig {
        .init(
            actionButton: .init(buttonAction: { [weak vm] in vm?.fetchIntent() }),
            dismissButton: .init(buttonAction: { navigationVm.router.dismiss() })
        )
    }

    private var successView: some View {
        hForm {}
            .hFormTitle(
                // TODO: Add "Change mileage" / "Ändra körsträcka" to Lokalise
                title: .init(.small, .body2, "Ändra körsträcka", alignment: .leading),
                // TODO: Add "Choose how far the car is driven per year" / "Välj hur långt bilen körs per år" to Lokalise
                subTitle: .init(.small, .body2, "Välj hur långt bilen körs per år")
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
                    title: vm.contract.displayName,
                    subtitle: vm.contract.exposureName,
                    pillowImage: vm.contract.typeOfContract?.pillowType.bgImage
                )
            }
            VStack(spacing: .padding4) {
                // TODO: Add "Mileage per year" / "Körsträcka per år" to Lokalise
                DropdownView(value: vm.selectedQuote?.displayName ?? "", placeHolder: "Körsträcka per år") {
                    navigationVm.isPickerPresented = .init()
                }
                .accessibilityHint(L10n.voiceoverPressTo + " " + L10n.contractEditInfo)
                if vm.isLowerThanCurrentSelected {
                    hSection {
                        // TODO: Add "If the car is driven further than you have chosen, the compensation can be lower in case of damage. You can change the mileage whenever you want." / "Om bilen körs längre än du har valt kan ersättningen bli lägre vid en skada. Du kan ändra körsträckan när du vill." to Lokalise
                        InfoCard(
                            text: "Om bilen körs längre än du har valt kan ersättningen bli lägre vid en skada. "
                                + "Du kan ändra körsträckan när du vill.",
                            type: .info
                        )
                    }
                }
            }
            .hFieldSize(.small)
            if let selectedQuote = vm.selectedQuote {
                hRow {
                    PriceField(
                        viewModel: .init(
                            initialValue: nil,
                            newValue: selectedQuote.totalCost.net,
                            title: L10n.tierFlowTotal,
                            subTitle: previousPriceSubtitle
                        )
                    )
                }
            }
        }
    }

    private var previousPriceSubtitle: String? {
        guard !vm.isCurrentSelected, let current = vm.intent?.currentTotalCost else { return nil }
        return L10n.tierFlowPreviousPrice(current.net.priceFormat(PriceFormatting.perMonth))
    }

    private var buttons: some View {
        hSection {
            VStack(spacing: .padding8) {
                hContinueButton {
                    navigationVm.router.push(ChangeMileageRouterActions.summary)
                }
                .disabled(vm.isCurrentSelected)
                // TODO: Add "How far do I drive?" / "Hur långt kör jag?" to Lokalise
                hButton(.large, .ghost, content: .init(title: "Hur långt kör jag?")) {
                    // TODO: Add the explanation copy for "How far do I drive?" to Lokalise once product has provided it
                    navigationVm.isHowFarDoIDriveInfoPresented = .init(
                        title: "Hur långt kör jag?",
                        description: "Räkna med all körning under ett år, av alla som kör bilen. "
                            + "Jämför gärna mätarställningen med förra årets besiktning."
                    )
                }
            }
        }
        .sectionContainerStyle(.transparent)
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> ChangeMileageClient in ChangeMileageClientDemo() })
    let contract = ChangeMileageContract(
        contractId: "contractId",
        displayName: "Bilförsäkring Helförsäkring",
        exposureName: "ABC 123 • Volvo XC40",
        typeOfContract: .seCarFull
    )
    let navigationVm = ChangeMileageNavigationViewModel(input: .init(contracts: [contract]))
    return ChangeMileageLandingScreen(vm: navigationVm.vm!)
        .environment(navigationVm)
}
