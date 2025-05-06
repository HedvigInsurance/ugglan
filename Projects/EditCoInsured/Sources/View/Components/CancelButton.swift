import SwiftUI
import hCore
import hCoreUI

struct CancelButton: View {
    @EnvironmentObject private var editCoInsuredNavigation: EditCoInsuredNavigationViewModel
    @EnvironmentObject private var router: Router

    var body: some View {
        hSection {
            hButton.LargeButton(type: .ghost) {
                editCoInsuredNavigation.editCoInsuredConfig = nil
                router.dismiss()
            } content: {
                hText(L10n.generalCancelButton)
            }
        }
        .sectionContainerStyle(.transparent)
    }
}
