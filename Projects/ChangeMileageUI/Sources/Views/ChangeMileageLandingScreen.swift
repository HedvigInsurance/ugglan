import ChangeMileageCore
import SwiftUI
import hCore
import hCoreUI

struct ChangeMileageLandingScreen: View {
    @Bindable var vm: ChangeMileageViewModel
    @Environment(ChangeMileageNavigationViewModel.self) var navigationVm

    var body: some View {
        ProcessingStateView(
            loadingViewText: L10n.changeMileageLoadingState,
            state: $vm.viewState
        )
        .hStateViewCustomSuccessView {
            successView
        }
        .hStateViewButtonConfig(errorButtons)
    }

    private var errorButtons: StateViewButtonConfig {
        .init(
            actionButton: vm.canRetryIntent ? .init(buttonAction: { [weak vm] in vm?.fetchIntent() }) : nil,
            dismissButton: .init(buttonAction: { navigationVm.router.dismiss() })
        )
    }

    private var successView: some View {
        hForm {}
            .hFormTitle(
                title: .init(.small, .body2, L10n.changeMileageOptionTitle, alignment: .leading),
                subTitle: .init(.small, .body2, L10n.changeMileageScreenSubtitle)
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
                DropdownView(value: vm.selectedQuote?.displayName ?? "", placeHolder: L10n.changeMileageLabel) {
                    navigationVm.isPickerPresented = .init()
                }
                .accessibilityHint(L10n.voiceoverPressTo + " " + L10n.contractEditInfo)
                if vm.isLowerThanCurrentSelected {
                    hSection {
                        InfoCard(
                            text: L10n.changeMileageNotice,
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
                hButton(.large, .ghost, content: .init(title: L10n.changeMileageInfoButton)) {
                    navigationVm.isHowFarDoIDriveInfoPresented = .init(
                        title: L10n.changeMileageInfoButton,
                        description: L10n.changeMileageInfoText
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
