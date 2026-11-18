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
        // TODO: Add "Your mileage will be %1$@ per year from %2$@, and your new price is %3$@." / "Din körsträcka blir %1$@ per år från %2$@ och ditt nya pris är %3$@." to Lokalise
        return "Din körsträcka blir \(mileage) per år från \(date) och ditt nya pris är \(price)."
    }

    private var errorButtons: StateViewButtonConfig {
        .init(
            actionButton: .init(buttonAction: { [weak navigationVm] in navigationVm?.router.pop() }),
            dismissButton: .init(buttonAction: { [weak navigationVm] in navigationVm?.router.dismiss() })
        )
    }
}
