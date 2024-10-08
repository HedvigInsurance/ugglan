import SwiftUI
import hCore
import hCoreUI

struct SelectInsuranceScreen: View {
    @ObservedObject var vm: ChangeTierViewModel
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel

    init(
        vm: ChangeTierViewModel
    ) {
        self.vm = vm
    }

    var body: some View {
        ItemPickerScreen<ChangeTierContract>(
            config: .init(
                items: {
                    let contracts = vm.changeTierInput.contractIds
                    let items = contracts.map({
                        (
                            object: $0,
                            displayName: ItemModel(
                                title: $0.contractDisplayName,
                                subTitle: $0.contractExposureName
                            )
                        )
                    })
                    return items
                }(),
                preSelectedItems: { [] },
                onSelected: { selected in
                    if let selectedContract = selected.first?.0 {
                        changeTierNavigationVm.router.push(selectedContract)
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
            title: .init(.small, .body2, L10n.terminationFlowTitle, alignment: .leading),
            subTitle: .init(.small, .body2, "Select the insurance you want to edit")
        )
        .withDismissButton()
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> ChangeTierClient in ChangeTierClientDemo() })
    return SelectInsuranceScreen(
        vm: .init(
            changeTierInput: .init(
                source: .betterCoverage,
                contractIds: [
                    ChangeTierContract(
                        contractId: "contractId1",
                        contractDisplayName: "contractDisplayName",
                        contractExposureName: "contractExposureName"
                    ),
                    ChangeTierContract(
                        contractId: "contractId2",
                        contractDisplayName: "contractDisplayName",
                        contractExposureName: "contractExposureName"
                    ),
                ]
            )
        )
    )
}
