import SwiftUI
import hCore
import hCoreUI

struct SelectInsuranceScreen: View {
    let changeTierContractsInput: ChangeTierContractsInput
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel

    init(changeTierContractsInput: ChangeTierContractsInput) {
        self.changeTierContractsInput = changeTierContractsInput
    }

    var body: some View {
        ItemPickerScreen<ChangeTierContract>(
            config: .init(
                items: {
                    let items = changeTierContractsInput.contracts.map({
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
                        changeTierNavigationVm.vm = .init(
                            changeTierInput: .init(
                                source: changeTierContractsInput.source,
                                contractId: selectedContract.contractId
                            )
                        )
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
        changeTierContractsInput: .init(
            source: .betterCoverage,
            contracts: [
                .init(
                    contractId: "contractId",
                    contractDisplayName: "displayName",
                    contractExposureName: "exposureName"
                )

            ]
        )
    )
}
