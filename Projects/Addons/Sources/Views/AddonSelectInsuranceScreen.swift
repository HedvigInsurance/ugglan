import Combine
import SwiftUI
import hCore
import hCoreUI

public struct AddonSelectInsuranceScreen: View {
    @EnvironmentObject var changeAddonNavigationVm: ChangeAddonNavigationViewModel
    @StateObject var vm = AddonSelectInsuranceScreenViewModel()
    @ObservedObject var changeAddonVm: ChangeAddonViewModel

    public var body: some View {
        successView.loading($changeAddonVm.fetchAddonsViewState)
            .hErrorViewButtonConfig(
                .init(
                    actionButton: .init(
                        buttonTitle: L10n.openChat,
                        buttonAction: {
                            changeAddonNavigationVm.router.dismiss()
                            NotificationCenter.default.post(name: .openChat, object: ChatType.newConversation)
                        }
                    )
                )
            )
    }

    private var successView: some View {
        ItemPickerScreen<AddonConfig>(
            config: .init(
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
                            contractId: selectedContract.contractId
                        )
                        vm.observer = changeAddonNavigationVm.changeAddonVm!.$fetchAddonsViewState
                            .sink { value in
                                vm.processingState = value
                            }
                    }
                },
                singleSelect: true,
                attachToBottom: true,
                disableIfNoneSelected: true,
                hButtonText: L10n.generalContinueButton,
                fieldSize: .small
            )
        )
        .hFormTitle(
            title: .init(.small, .heading2, L10n.addonFlowSelectInsuranceTitle, alignment: .leading),
            subTitle: .init(.small, .heading2, L10n.addonFlowSelectInsuranceSubtitle)
        )
        .hFieldSize(.small)
        .trackErrorState(for: $vm.processingState)
        .hButtonIsLoading(vm.processingState == .loading)
        .onChange(of: vm.processingState) { value in
            switch value {
            case .success:
                changeAddonNavigationVm.router.push(ChangeAddonRouterActions.addonLandingScreen)
            default:
                break
            }
        }
    }
}

class AddonSelectInsuranceScreenViewModel: ObservableObject {
    @Published var processingState = ProcessingState.success
    var observer: AnyCancellable?
    @Published var selectedItems: [AddonConfig] = []
}

#Preview {
    AddonSelectInsuranceScreen(changeAddonVm: .init(contractId: "contractId"))
        .environmentObject(
            ChangeAddonNavigationViewModel(
                input: .init(
                    contractConfigs: [
                        .init(contractId: "1", exposureName: "1", displayName: "1"),
                        .init(contractId: "2", exposureName: "2", displayName: "2"),

                    ]
                )
            )
        )
}
