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
                "Update necessary".hText(.title2)
                "It seems like you are using an app version that is not supported anymore. To use Hedvig, update to the latest version on the App Store."
                    .hText(.body)
                    .foregroundColor(hLabelColor.secondary)
                    .multilineTextAlignment(.center)
                hButton.SmallButtonOutlined {
                    if let url = URL(string: "itms-apps://apple.com/app/id1303668531") {
                        UIApplication.shared.open(url)
                    }
                } content: {
                    HStack {
                        Image(uiImage: hCoreUIAssets.external.image)
                        "Open App Store".hText()
                    }
                }
            }.padding()
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


