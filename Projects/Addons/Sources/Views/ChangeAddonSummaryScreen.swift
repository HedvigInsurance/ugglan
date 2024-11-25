import SwiftUI
import hCore
import hCoreUI

struct ChangeAddonSummaryScreen: View {
    let quoteSummaryVm: QuoteSummaryViewModel

    init(
        changeAddonNavigationVm: ChangeAddonNavigationViewModel
    ) {
        quoteSummaryVm = changeAddonNavigationVm.changeAddonVm.asQuoteSummaryViewModel(
            changeAddonNavigationVm: changeAddonNavigationVm
        )
    }

    var body: some View {
        QuoteSummaryScreen(vm: quoteSummaryVm)
    }
}

extension ChangeAddonViewModel {
    func asQuoteSummaryViewModel(changeAddonNavigationVm: ChangeAddonNavigationViewModel) -> QuoteSummaryViewModel {

        /* TODO: IMPLEMENT */
        let vm = QuoteSummaryViewModel(contract: [], total: .init(amount: "220", currency: "SEK")) {

        }

        return vm
    }
}
