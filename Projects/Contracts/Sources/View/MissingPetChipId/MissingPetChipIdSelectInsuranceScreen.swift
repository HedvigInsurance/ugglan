import SwiftUI
import hCore
import hCoreUI

struct MissingPetChipIdSelectInsuranceScreen: View {
    let contracts: [Contract]
    let onContractSelected: (Contract) -> Void
    let itemPickerConfig: ItemConfig<Contract>

    init(
        contracts: [Contract],
        onContractSelected: @escaping (Contract) -> Void
    ) {
        self.contracts = contracts
        self.onContractSelected = onContractSelected
        itemPickerConfig = .init(
            items: contracts.map {
                (
                    object: $0,
                    displayName: .init(
                        title: $0.currentAgreement?.productVariant.displayName ?? "",
                        subTitle: $0.exposureDisplayName
                    )
                )
            },
            preSelectedItems: { [] },
            onSelected: { selected in
                if let contract = selected.first?.0 {
                    onContractSelected(contract)
                }
            },
            buttonText: L10n.generalContinueButton
        )
    }

    var body: some View {
        ContractSelectView(
            itemPickerConfig: itemPickerConfig,
            title: L10n.SelectInsurance.NavigationBar.CenterElement.title,
            subtitle: nil,
            modally: true,
        )
        .embededInNavigation(
            options: [.largeNavigationBar],
            tracking: String(describing: MissingPetChipIdSelectInsuranceScreen.self)
        )
    }
}

#Preview {
    MissingPetChipIdSelectInsuranceScreen(contracts: [], onContractSelected: { _ in })
}
