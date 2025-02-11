import SwiftUI
import hCore
import hCoreUI

public struct ConfirmChangeTierScreen: View {
    @EnvironmentObject var changeTierNavigationVm: ChangeTierNavigationViewModel

    public var body: some View {
        ConfirmChangesScreen(
            title: L10n.confirmChangesTitle,
            subTitle: L10n.confirmChangesSubtitle(
                changeTierNavigationVm.vm.activationDate?.displayDateDDMMMYYYYFormat ?? ""
            ),
            buttons: .init(
                mainButton: .init(
                    buttonTitle: L10n.generalConfirm,
                    buttonAction: {
                        changeTierNavigationVm.isConfirmTierPresented = false
                        changeTierNavigationVm.vm.commitTier()
                        changeTierNavigationVm.router.push(ChangeTierRouterActionsWithoutBackButton.commitTier)
                    }
                ),
                dismissButton: .init(
                    buttonTitle: L10n.generalCloseButton,
                    buttonAction: {
                        changeTierNavigationVm.isConfirmTierPresented = false
                    }
                )
            )
        )
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> ChangeTierClient in ChangeTierClientDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return ConfirmChangeTierScreen()
        .environmentObject(
            ChangeTierNavigationViewModel(
                changeTierContractsInput: .init(source: .changeTier, contracts: []),
                onChangedTier: {}
            )
        )
}
