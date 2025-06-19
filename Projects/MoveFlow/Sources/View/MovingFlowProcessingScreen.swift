import CrossSell
import SwiftUI
import hCore
import hCoreUI

struct MovingFlowProcessingScreen: View {
    @EnvironmentObject var movingFlowNavigationVm: MovingFlowNavigationViewModel
    var onSuccessButtonAction: () -> Void
    var onErrorButtonAction: () -> Void

    @ObservedObject var movingFlowConfirmVm: MovingFlowConfirmViewModel

    var body: some View {
        ProcessingStateView(
            loadingViewText: L10n.changeAddressMakingChanges,
            successViewTitle: L10n.changeAddressSuccessTitle,
            successViewBody: L10n.changeAddressSuccessSubtitle(
                movingFlowNavigationVm.movingDate
            ),
            successViewButtonAction: {
                onSuccessButtonAction()
            },
            state: $movingFlowConfirmVm.viewState,
            duration: 6
        )
        .hStateViewButtonConfig(errorButtons)
        .onDeinit { [weak movingFlowConfirmVm] in
            if movingFlowConfirmVm?.viewState == .success {
                NotificationCenter.default.post(
                    name: .openCrossSell,
                    object: CrossSellInfo(type: .movingFlow)
                )
            }
        }
    }

    private var errorButtons: StateViewButtonConfig {
        .init(
            actionButton: .init(buttonAction: {
                onErrorButtonAction()
            }),
            dismissButton: nil
        )
    }
}

struct SuccessScreen_Previews: PreviewProvider {
    static var previews: some View {
        Localization.Locale.currentLocale.send(.sv_SE)
        Dependencies.shared.add(module: Module { () -> MoveFlowClient in MoveFlowClientDemo() })

        return MovingFlowProcessingScreen(
            onSuccessButtonAction: {},
            onErrorButtonAction: {},
            movingFlowConfirmVm: .init()
        )
        .environmentObject(MovingFlowNavigationViewModel())
    }
}
