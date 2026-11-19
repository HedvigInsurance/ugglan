import ChangeMileageCore
import SwiftUI
import hCore
import hCoreUI

struct ChangeMileageProcessingScreen: View {
    @Bindable var vm: ChangeMileageViewModel
    @Environment(ChangeMileageNavigationViewModel.self) var navigationVm

    var body: some View {
        ProcessingStateView(
            loadingViewText: L10n.tierFlowCommitProcessingLoadingTitle,
            successViewTitle: L10n.tierFlowCommitProcessingTitle,
            successViewBody: successBody,
            successViewButtonAction: { [weak navigationVm] in
                navigationVm?.router.dismiss()
            },
            state: $vm.commitState
        )
        .hStateViewButtonConfig(errorButtons)
        .onChange(of: vm.commitState) { _, state in
            if state == .success {
                NotificationCenter.default.post(name: .mileageChanged, object: nil)
            }
        }
    }

    private var successBody: String {
        let mileage = vm.selectedQuote?.displayName ?? ""
        let date = vm.intent?.activationDate.displayDateDDMMMYYYYFormat ?? ""
        let price = vm.selectedQuote?.totalCost.net.formattedAmountPerMonth ?? ""
        return L10n.changeMileageSuccess(mileage, date, price)
    }

    private var errorButtons: StateViewButtonConfig {
        .init(
            actionButton: .init(buttonAction: { [weak navigationVm] in navigationVm?.router.pop() }),
            dismissButton: .init(buttonAction: { [weak navigationVm] in navigationVm?.router.dismiss() })
        )
    }
}
