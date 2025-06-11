import Foundation
import SwiftUI
import hCore
import hCoreUI

struct LaunchScreen: View {
    @State private var offset: CGFloat = -24
    var body: some View {
        Image(uiImage: hCoreUIAssets.hedvig.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 200, height: 40)
            .offset(y: offset)
            .onAppear {
                for i in 1...20 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.001 * Double(i)) {
                        let topOffset = UIApplication.shared.safeArea?.top
                        if topOffset == 62 {
                            offset = -16
                        }
                    }
                }
            }
            .accessibilityHidden(true)
    }
}
