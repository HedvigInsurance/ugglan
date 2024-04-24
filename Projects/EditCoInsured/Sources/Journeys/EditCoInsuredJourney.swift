import EditCoInsuredShared
import Presentation
import SwiftUI
import hCore
import hCoreUI

public struct EditCoInsuredViewJourney: View {
    let configs: [InsuredPeopleConfig]

    public init(configs: [InsuredPeopleConfig]) {
        self.configs = configs
    }

    public var body: some View {
        if configs.count > 1 {
            openSelectInsurance(configs: configs)
        } else if let config = configs.first {
            if configs.first?.numberOfMissingCoInsuredWithoutTermination ?? 0 > 0 {
                openNewInsuredPeopleScreen(config: config)
            } else {
                openInsuredPeopleScreen(with: config)
            }
        }
    }

    func openSelectInsurance(configs: [InsuredPeopleConfig]) -> some View {
        CheckboxPickerScreen<InsuredPeopleConfig>(
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
            onSelected: { selectedConfigs in
                if let selectedConfig = selectedConfigs.first {
                    let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
                    if let object = selectedConfig.0 {
                        if object.numberOfMissingCoInsuredWithoutTermination > 0 {
                            store.send(
                                .coInsuredNavigationAction(
                                    action: .openInsuredPeopleNewScreen(config: object)
                                )
                            )
                        } else {
                            store.send(
                                .coInsuredNavigationAction(
                                    action: .openInsuredPeopleScreen(config: object)
                                )
                            )
                        }
                    }
                }
            },
            onCancel: {
            },
            singleSelect: true,
            hButtonText: L10n.generalContinueButton
        )
    }

    func openNewInsuredPeopleScreen(config: InsuredPeopleConfig) -> some View {
        let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
        store.coInsuredViewModel.config = config
        return InsuredPeopleNewScreen(vm: store.coInsuredViewModel, intentVm: store.intentViewModel)
    }

    func openInsuredPeopleScreen(with config: InsuredPeopleConfig) -> some View {
        let store: EditCoInsuredStore = globalPresentableStoreContainer.get()
        store.coInsuredViewModel.config = config
        return InsuredPeopleScreen(vm: store.coInsuredViewModel, intentVm: store.intentViewModel)
    }
}
