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
        ZStack {
            VStack(spacing: 24) {
                Image(uiImage: hCoreUIAssets.warningTriangle.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                L10n.AppUpdateNeeded.title.hText(.title2)
                L10n.AppUpdateNeeded.body
                    .hText(.body)
                    .foregroundColor(hLabelColor.secondary)
                    .multilineTextAlignment(.center)
                hButton.SmallButtonOutlined {
                    if let url = URL(string: L10n.AppUpdateNeeded.hedvigAppStoreLink) {
                        UIApplication.shared.open(url)
                    }
                } content: {
                    HStack {
                        L10n.AppUpdateNeeded.appStoreButton.hText()
                        Image(uiImage: hCoreUIAssets.external.image)
                    }
                }
            }
            .padding()
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
