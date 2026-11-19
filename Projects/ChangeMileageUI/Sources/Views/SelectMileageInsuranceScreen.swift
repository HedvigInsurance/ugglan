import ChangeMileageCore
import SwiftUI
import hCore
import hCoreUI

struct SelectMileageInsuranceScreen: View {
    private let itemPickerConfig: ItemConfig<ChangeMileageContract>

    init(navigationVm: ChangeMileageNavigationViewModel) {
        itemPickerConfig = .init(
            items: navigationVm.input.contracts.map {
                (object: $0, displayName: ItemModel(title: $0.displayName, subTitle: $0.exposureName))
            },
            preSelectedItems: { [] },
            onSelected: { [weak navigationVm] selected in
                if let contract = selected.first?.0 {
                    navigationVm?.start(with: contract)
                }
            },
            buttonText: L10n.generalContinueButton
        )
    }

    var body: some View {
        ContractSelectView(
            itemPickerConfig: itemPickerConfig,
            title: L10n.changeMileageOptionTitle,
            subtitle: L10n.tierFlowSelectInsuranceSubtitle
        )
    }
}
