import SwiftUI
import hCore
import hCoreUI

public struct ConfirmChangeAddonScreen: View {
    @EnvironmentObject var addonNavigationVm: ChangeAddonNavigationViewModel

    public var body: some View {
        ConfirmChangesScreen(
            title: L10n.addonFlowConfirmationTitle,
            subTitle: L10n.addonFlowConfirmationDescription(
                addonNavigationVm.changeAddonVm?.addonOffer?.activationDate?
                    .displayDateDDMMMYYYYFormat ?? ""
            ),
            buttons: .init(
                mainButton: .init(
                    buttonTitle: L10n.addonFlowConfirmationButton,
                    buttonAction: {
                        addonNavigationVm.isAddonProcessingPresented = true
                        addonNavigationVm.isConfirmAddonPresented = false
                        Task {
                            await addonNavigationVm.changeAddonVm?.submitAddons()
                        }
                    }
                ),
                dismissButton: .init(
                    buttonAction: {
                        addonNavigationVm.isConfirmAddonPresented = false
                    }
                )
            )
        )
    }
}

#Preview {
    Dependencies.shared.add(module: Module { () -> AddonsClient in AddonsClientDemo() })
    Dependencies.shared.add(module: Module { () -> DateService in DateService() })
    return ConfirmChangeAddonScreen()
        .environmentObject(ChangeAddonNavigationViewModel(input: .init(addonSource: .insurances)))
}
