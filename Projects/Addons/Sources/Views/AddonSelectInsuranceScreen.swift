import SwiftUI
import hCore
import hCoreUI

public struct AddonSelectInsuranceScreen: View {
    @EnvironmentObject var changeAddonNavigationVm: ChangeAddonNavigationViewModel

    public var body: some View {
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
                preSelectedItems: { [] },
                onSelected: { selected in
                    if let selectedContract = selected.first?.0 {
                        changeAddonNavigationVm.changeAddonVm.contractId = selectedContract.contractId
                        changeAddonNavigationVm.router.push(ChangeAddonRouterActions.addonLandingScreen)
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
            title: .init(.small, .heading2, L10n.addonFlowTitle, alignment: .leading),
            subTitle: .init(.small, .heading2, L10n.addonFlowSelectInsuranceSubtitle)
        )
        .hFieldSize(.small)
    }
}
