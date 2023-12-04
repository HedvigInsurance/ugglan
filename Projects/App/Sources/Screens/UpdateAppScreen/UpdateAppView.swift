import Flow
import Form
import Foundation
import Presentation
import SwiftUI
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct UpdateAppView: View {
    var body: some View {
        RetryView(
            title: L10n.AppUpdateNeeded.title,
            subtitle: L10n.AppUpdateNeeded.body,
            retryTitle: L10n.AppUpdateNeeded.appStoreButton
        ) {
            if let url = URL(string: L10n.AppUpdateNeeded.hedvigAppStoreLink) {
                UIApplication.shared.open(url)
            }
        }
    }
}

extension AppJourney {
    static var updateApp: some JourneyPresentation {
        HostingJourney(
            rootView: UpdateAppView()
        )
    }
}

struct UpdateAppView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateAppView()
    }
}
