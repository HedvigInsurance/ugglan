import EditCoInsuredShared
import SwiftUI
import hCore
import hCoreUI

struct CoInsuredSelectInsuranceScreen: View {
    @ObservedObject var editCoInsuredNavigationVm: EditCoInsuredNavigationViewModel
    @ObservedObject var editCoInsuredViewModel: EditCoInsuredViewModel
    @EnvironmentObject var router: Router
    let configs: [InsuredPeopleConfig]

    init(
        configs: [InsuredPeopleConfig],
        editCoInsuredNavigationVm: EditCoInsuredNavigationViewModel,
        editCoInsuredViewModel: EditCoInsuredViewModel
    ) {
        self.configs = configs
        self.editCoInsuredNavigationVm = editCoInsuredNavigationVm
        self.editCoInsuredViewModel = editCoInsuredViewModel
    }

    var body: some View {
        ContractSelectView(
            itemPickerConfig: itemPickerConfig,
            title: L10n.SelectInsurance.NavigationBar.CenterElement.title,
            subtitle: L10n.tierFlowSelectInsuranceSubtitle,
            modally: true
        )
    }

    private var itemPickerConfig: ItemConfig<InsuredPeopleConfig> {
        return ItemConfig<InsuredPeopleConfig>(
            items: {
                return configs.compactMap({
                    (object: $0, displayName: .init(title: $0.displayName))
                })
            }(),
            preSelectedItems: {
                if let first = configs.first {
                    return [first]
                }
                return []
            },
            onSelected: { [weak editCoInsuredViewModel] selectedConfigs in
                if let selectedConfig = selectedConfigs.first {
                    if let object = selectedConfig.0 {
                        editCoInsuredViewModel?.editCoInsuredModelDetent = nil
                        editCoInsuredViewModel?.editCoInsuredModelFullScreen = .init(contractsSupportingCoInsured: {
                            return [object]
                        })
                        self.editCoInsuredNavigationVm.coInsuredViewModel.initializeCoInsured(with: object)
                    }
                }
            },
            onCancel: { [weak router] in
                router?.dismiss()
            },
            buttonText: L10n.generalContinueButton
        )
    }
}
