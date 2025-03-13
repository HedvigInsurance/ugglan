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
        self.itemPickerConfig = .init(
            items: {
                let addonContractConfigs: [AddonConfig] = changeAddonNavigationVm.input.contractConfigs ?? []
                let items = addonContractConfigs.map({
                    (
                        object: $0,
                        displayName: ItemModel(
                            title: $0.displayName,
                            subTitle: $0.exposureName
                        )
                    )
                })

                return items
            }(),
            preSelectedItems: { vm.selectedItems },
            onSelected: { selected in
                if let selectedContract = selected.first?.0 {
                    vm.selectedItems = selected.compactMap({ $0.0 })
                    changeAddonNavigationVm.changeAddonVm = .init(
                        contractId: selectedContract.contractId,
                        addonSource: changeAddonNavigationVm.input.addonSource
                    )
                    vm.observer = changeAddonNavigationVm.changeAddonVm!.$fetchAddonsViewState
                        .sink { [weak vm] value in
                            withAnimation {
                                vm?.processingState = value
                            }
                            if value == .success {
                                changeAddonNavigationVm.router.push(ChangeAddonRouterActions.addonLandingScreen)
                                vm?.observer = nil
                            }
                        }
                }
            },
            singleSelect: true,
            attachToBottom: true,
            disableIfNoneSelected: true,
            hButtonText: L10n.generalContinueButton,
            fieldSize: .small
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
        ItemPickerScreen<AddonConfig>(
            config: itemPickerConfig
        )
        .hFormTitle(
            title: .init(.small, .heading2, L10n.addonFlowSelectInsuranceTitle, alignment: .leading),
            subTitle: .init(.small, .heading2, L10n.addonFlowSelectInsuranceSubtitle)
        )
        .hFieldSize(.small)
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
