import Presentation
import SwiftUI
import hCore
import hCoreUI

struct AboutBusinessModelView: View {
    var body: some View {
        hForm {
            hSection {
                hText(
                    L10n.businessModelInfoDialogText,
                    style: .body
                )
                .foregroundColor(hLabelColor.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .sectionContainerStyle(.transparent)
        }
    }
}

extension AboutBusinessModelView {
    var journey: some JourneyPresentation {
        HostingJourney(
            ProfileStore.self,
            rootView: self,
            style: .detented(.scrollViewContentSize),
            options: [.defaults, .prefersLargeTitles(true), .largeTitleDisplayMode(.always)]
        ) { _ in
            DismissJourney()
        }
        .configureTitle(L10n.businessModelInfoDialogTitle)
        .withDismissButton
    }
}
