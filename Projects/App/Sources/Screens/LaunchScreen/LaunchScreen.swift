import Foundation
import SwiftUI
import hCore
import hCoreUI

struct LaunchScreen: View {
    var body: some View {
        Image(uiImage: hCoreUIAssets.wordmark.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 40)
            .offset(y: -24)
            .ignoresSafeArea()
    }
}
