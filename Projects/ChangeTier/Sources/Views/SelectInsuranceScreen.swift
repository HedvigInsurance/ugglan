import SwiftUI
import hCore
import hCoreUI

struct SelectInsuranceScreen: View {
    let changeTierContractsInput: ChangeTierContractsInput
    @ObservedObject var changeTierNavigationVm: ChangeTierNavigationViewModel
    let itemPickerConfig: ItemConfig<ChangeTierContract>
    init(
        changeTierContractsInput: ChangeTierContractsInput,
        changeTierNavigationVm: ChangeTierNavigationViewModel
    ) {
        self.changeTierContractsInput = changeTierContractsInput
        self.changeTierNavigationVm = changeTierNavigationVm
        self.itemPickerConfig = .init(
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
                        changeTierInput: .contractWithSource(
                            data: .init(
                                source: changeTierContractsInput.source,
                                contractId: selectedContract.contractId
                            )
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
    }

    var body: some View {
        ItemPickerScreen<ChangeTierContract>(
            config: itemPickerConfig
        )
        .hFormTitle(
            title: .init(.small, .body2, L10n.tierFlowTitle, alignment: .leading),
            subTitle: .init(.small, .body2, L10n.tierFlowSelectInsuranceSubtitle)
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
        ),
        changeTierNavigationVm: .init(
            changeTierContractsInput: .init(
                source: .betterCoverage,
                contracts: [
                    .init(
                        contractId: "contractId",
                        contractDisplayName: "displayName",
                        contractExposureName: "exposureName"
                    )

                ]
            ),
            onChangedTier: {

            }
        )
    )
}
