import Combine
import SwiftUI
import hCore
import hCoreUI

public struct AddonSelectInsuranceScreen: View {
    @ObservedObject var changeAddonNavigationVm: ChangeAddonNavigationViewModel
    @ObservedObject var vm: AddonSelectInsuranceScreenViewModel
    let itemPickerConfig: ItemConfig<AddonConfig>

    init(
        changeAddonNavigationVm: ChangeAddonNavigationViewModel,
        vm: AddonSelectInsuranceScreenViewModel = AddonSelectInsuranceScreenViewModel()
    ) {
        self.changeAddonNavigationVm = changeAddonNavigationVm
        self.vm = vm
        itemPickerConfig = .init(
            items: {
                let addonContractConfigs = changeAddonNavigationVm.input.contractConfigs ?? []
                let items = addonContractConfigs.map {
                    (
                        object: $0,
                        displayName: ItemModel(
                            title: $0.displayName,
                            subTitle: $0.exposureName
                        )
                    )
                }

                return items
            }(),
            preSelectedItems: { vm.selectedItems },
            onSelected: { selected in
                if let selectedContract = selected.first?.0 {
                    vm.selectedItems = selected.compactMap(\.0)
                    changeAddonNavigationVm.changeAddonVm = .init(
                        config: selectedContract,
                        addonSource: changeAddonNavigationVm.input.addonSource
                    )
                    vm.observer = changeAddonNavigationVm.changeAddonVm!.$fetchAddonsViewState
                        .sink { [weak vm] value in
                            withAnimation {
                                vm?.processingState = value
                            }
                            guard value == .success else { return }
                            changeAddonNavigationVm.router.push(ChangeAddonRouterActions.addonLandingScreen)
                            vm?.observer = nil
                        }
                }
            },
            buttonText: L10n.generalContinueButton
        )
    }

    public var body: some View {
        successView
            .loadingWithButtonLoading($vm.processingState)
            .hStateViewButtonConfig(
                .init(
                    actionButton: .init(
                        buttonAction: {
                            withAnimation {
                                vm.observer = nil
                                vm.processingState = .success
                            }
                        }
                    )
                )
            )
    }

    private var successView: some View {
        ContractSelectView(
            itemPickerConfig: itemPickerConfig,
            title: L10n.addonFlowSelectInsuranceTitle,
            subtitle: L10n.addonFlowSelectInsuranceSubtitle
        )
    }
}

class AddonSelectInsuranceScreenViewModel: ObservableObject {
    @Published var processingState = ProcessingState.success
    var observer: AnyCancellable?
    @Published var selectedItems: [AddonConfig] = []
}

#Preview {
    Dependencies.shared.add(module: Module { () -> AddonsClient in AddonsClientDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return AddonSelectInsuranceScreen(
        changeAddonNavigationVm: ChangeAddonNavigationViewModel(
            input: .init(
                addonSource: .insurances,
                contractConfigs: [
                    .init(contractId: "1", exposureName: "1", displayName: "1"),
                    .init(contractId: "2", exposureName: "2", displayName: "2"),
                ]
            )
        )
    )
}
