import SwiftUI
import hCoreUI

struct CancelButton: View {
    @Environment(EditStakeholdersNavigationViewModel.self) private var editStakeholdersNavigation
    @EnvironmentObject private var router: NavigationRouter

    var body: some View {
        hCancelButton {
            editStakeholdersNavigation.editStakeholderConfig = nil
            router.dismiss()
        }
    }
}
