import hCore
import hCoreUI
import SwiftUI

struct CancelButton: View {
    @EnvironmentObject private var editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    @EnvironmentObject private var router: Router

    var body: some View {
        hSection {
            hCancelButton {
                editCoInsuredNavigation.editCoInsuredConfig = nil
                router.dismiss()
            }
        }
        .sectionContainerStyle(.transparent)
    }
}
