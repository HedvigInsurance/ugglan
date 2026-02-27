import SwiftUI
import hCore
import hCoreUI

struct CoInsuredSelectInsuranceScreen: View {
    @ObservedObject private var editCoInsuredNavigationVm: EditCoInsuredNavigationViewModel
    @ObservedObject private var editCoInsuredViewModel: EditCoInsuredViewModel
    private let router: NavigationRouter
    private let itemPickerConfig: ItemConfig<InsuredPeopleConfig>
    init(
        configs: [InsuredPeopleConfig],
        editCoInsuredNavigationVm: EditCoInsuredNavigationViewModel,
        editCoInsuredViewModel: EditCoInsuredViewModel,
        router: NavigationRouter
    ) {
        self.editCoInsuredNavigationVm = editCoInsuredNavigationVm
        self.editCoInsuredViewModel = editCoInsuredViewModel
        self.router = router
        itemPickerConfig = ItemConfig<InsuredPeopleConfig>(
            items: configs.compactMap {
                (object: $0, displayName: .init(title: $0.displayName, subTitle: $0.exposureDisplayName))
            },
            preSelectedItems: {
                if let first = configs.first {
                    return [first]
                }
                return []
            },
            onSelected: { [weak editCoInsuredViewModel, weak editCoInsuredNavigationVm] selectedConfigs in
                if let selectedConfig = selectedConfigs.first {
                    if let object = selectedConfig.0 {
                        editCoInsuredViewModel?.editCoInsuredModelDetent = nil
                        editCoInsuredViewModel?.editCoInsuredModelFullScreen = .init(contractsSupportingCoInsured: {
                            [object]
                        })
                        editCoInsuredNavigationVm?.coInsuredViewModel.initializeCoInsured(with: object)
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
