import SwiftUI
import hCore
import hCoreUI

struct TerminationSelectInsuranceScreen: View {
    @ObservedObject private var vm: TerminationFlowNavigationViewModel
    let itemPickerConfig: ItemConfig<TerminationConfirmConfig>

    init(
        vm: TerminationFlowNavigationViewModel
    ) {
        self.vm = vm
        itemPickerConfig = .init(
            items: {
                let items = vm.configs.map {
                    (
                        object: $0,
                        displayName: ItemModel(
                            title: $0.contractDisplayName,
                            subTitle: $0.contractExposureName
                        )
                    )
                }
                return items
            }(),
            preSelectedItems: { [] },
            onSelected: { selected in
                if let selectedContract = selected.first?.0 {
                    let config = TerminationConfirmConfig(
                        contractId: selectedContract.contractId,
                        contractDisplayName: selectedContract.contractDisplayName,
                        contractExposureName: selectedContract.contractExposureName,
                        activeFrom: selectedContract.activeFrom,
                        typeOfContract: selectedContract.typeOfContract
                    )
                    Task {
                        vm.hasSelectInsuranceStep = true
                        vm.previousProgress = vm.progress
                        if let progress = vm.progress {
                            vm.previousProgress = progress
                            vm.progress = progress * 0.75 + 0.25
                        } else {
                            vm.progress = nil
                        }
                        await vm.startTermination(config: config, fromSelectInsurance: true)
                    }
                }
            },
            buttonText: L10n.generalContinueButton
        )
    }

    var body: some View {
        ContractSelectView(
            itemPickerConfig: itemPickerConfig,
            title: L10n.terminationFlowTitle,
            subtitle: L10n.terminationFlowBody
        )
    }
}
