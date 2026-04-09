import SwiftUI
import hCore
import hCoreUI

struct StakeholderSelectInsuranceScreen: View {
    @ObservedObject private var editStakeholdersNavigationVm: EditStakeholdersNavigationViewModel
    @ObservedObject private var editStakeholdersViewModel: EditStakeholdersViewModel
    private let router: NavigationRouter
    private let itemPickerConfig: ItemConfig<StakeholdersConfig>
    init(
        configs: [StakeholdersConfig],
        editStakeholdersNavigationVm: EditStakeholdersNavigationViewModel,
        editStakeholdersViewModel: EditStakeholdersViewModel,
        router: NavigationRouter
    ) {
        self.editStakeholdersNavigationVm = editStakeholdersNavigationVm
        self.editStakeholdersViewModel = editStakeholdersViewModel
        self.router = router
        itemPickerConfig = ItemConfig<StakeholdersConfig>(
            items: configs.compactMap {
                (object: $0, displayName: .init(title: $0.displayName, subTitle: $0.exposureDisplayName))
            },
            preSelectedItems: {
                if let first = configs.first {
                    return [first]
                }
                return []
            },
            onSelected: { [weak editStakeholdersViewModel, weak editStakeholdersNavigationVm] selectedConfigs in
                if let selectedConfig = selectedConfigs.first {
                    if let object = selectedConfig.0 {
                        editStakeholdersViewModel?.editStakeholderModelDetent = nil
                        editStakeholdersViewModel?.editStakeholderModelFullScreen = .init(
                            contractsSupportingStakeholders: {
                                [object]
                            })
                        editStakeholdersNavigationVm?.stakeholderViewModel.initializeStakeholders(with: object)
                    }
                }
            },
            onCancel: { [weak router] in
                router?.dismiss()
            },
            buttonText: L10n.generalContinueButton
        )
    }

    var body: some View {
        ContractSelectView(
            itemPickerConfig: itemPickerConfig,
            title: L10n.SelectInsurance.NavigationBar.CenterElement.title,
            subtitle: L10n.tierFlowSelectInsuranceSubtitle,
            modally: true
        )
    }
}
