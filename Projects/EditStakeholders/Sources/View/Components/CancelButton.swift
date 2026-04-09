import SwiftUI
import hCoreUI

struct CancelButton: View {
    @EnvironmentObject private var editStakeholdersNavigation: EditStakeholdersNavigationViewModel
    @EnvironmentObject private var router: NavigationRouter

    var body: some View {
        hCancelButton {
            editStakeholdersNavigation.editStakeholderConfig = nil
            router.dismiss()
        }
    }
}
