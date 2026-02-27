import SwiftUI
import hCoreUI

struct CancelButton: View {
    @EnvironmentObject private var editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    @EnvironmentObject private var router: NavigationRouter

    var body: some View {
        hCancelButton {
            editCoInsuredNavigation.editCoInsuredConfig = nil
            router.dismiss()
        }
    }
}
