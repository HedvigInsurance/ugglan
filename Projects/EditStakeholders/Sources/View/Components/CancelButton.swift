import SwiftUI
import hCoreUI

struct CancelButton: View {
    @Environment(EditStakeholdersNavigationViewModel.self) private var editStakeholdersNavigation
    @Environment(NavigationRouter.self) private var router

    var body: some View {
        hCancelButton {
            editStakeholdersNavigation.editStakeholderConfig = nil
            router.dismiss()
        }
    }
}
