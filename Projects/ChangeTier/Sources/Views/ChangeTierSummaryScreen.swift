import SwiftUI
import hCoreUI

struct ChangeTierSummaryScreen: View {
    @ObservedObject var vm: SelectTierViewModel
    @EnvironmentObject var selectTierNavigationVm: ChangeTierNavigationViewModel

    var body: some View {
        hForm {
            hText("summary screen")
        }
    }
}
