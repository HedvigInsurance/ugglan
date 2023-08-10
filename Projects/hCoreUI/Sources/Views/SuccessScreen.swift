import Presentation
import SwiftUI
import hCore

public struct SuccessScreen: View {
    let title: String
    public var body: some View {
        hSection {
            VStack(spacing: 20) {
                Spacer()
                Image(uiImage: hCoreUIAssets.tick.image)
                    .resizable()
                    .foregroundColor(hSignalColorNew.greenElement)
                    .frame(width: 24, height: 24)
                hText(title)
                Spacer()
            }
        }
        .sectionContainerStyle(.transparent)
    }
}
struct SuccessScreen_Previews: PreviewProvider {
    static var previews: some View {
        SuccessScreen(title: "SUCCESS")
    }
}

extension SuccessScreen {
    public static func journey(with title: String) -> some JourneyPresentation {
        HostingJourney(
            rootView: SuccessScreen(title: title),
            style: .detented(.large),
            options: [.prefersNavigationBarHidden(true)]
        )
        .hidesBackButton
    }
}
